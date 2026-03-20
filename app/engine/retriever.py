import os
import unicodedata
from difflib import SequenceMatcher
from azure.identity import DefaultAzureCredential
from azure.search.documents import SearchClient
from langchain_core.documents import Document

# --- AUXILIARES DE NORMALIZAÇÃO ---

def norm(texto: str) -> str:
    """Normaliza texto: remove títulos, acentos e coloca em lowercase."""
    if not texto:
        return ""
    titulos = ["srta. ", "dr. ", "dra. ", "sr. ", "sra. "]
    t_limpo = texto.lower()
    for t in titulos:
        t_limpo = t_limpo.replace(t, "")
    
    return "".join(
        c for c in unicodedata.normalize('NFD', t_limpo)
        if unicodedata.category(c) != 'Mn'
    ).strip()

def similaridade(a: str, b: str) -> float:
    """Calcula quão parecidas são duas strings (0.0 a 1.0)."""
    return SequenceMatcher(None, a, b).ratio()

def get_client():
    """Configura o cliente do Azure AI Search com Managed Identity."""
    endpoint = os.getenv("SEARCH_ENDPOINT")
    credential = DefaultAzureCredential()
    return SearchClient(endpoint=endpoint, index_name="vigilantes-index", credential=credential)

# --- FUNÇÕES PRINCIPAIS ---

def get_missing_staff_data(nome_faltante: str):
    """
    PASSO 1: Encontra o vigilante que faltou.
    Usa validação rigorosa para evitar 'falsos positivos' como o Ue da Silva.
    """
    client = get_client()
    try:
        results = client.search(search_text=nome_faltante, top=1)
        candidatos = list(results)
        
        if not candidatos:
            return None

        res = candidatos[0]
        n_usuario = norm(nome_faltante)
        n_banco = norm(res.get("nome_completo", ""))

        # Score de similaridade (0.8 aceita erros como Henry vs Henri)
        if similaridade(n_usuario, n_banco) < 0.8:
            return None

        return res
    except Exception as e:
        print(f"Erro ao buscar faltante: {e}")
        return None

def get_staff_retriever(lat, lon, query, max_dist_km=30):
    """
    PASSO 2: Busca os 5 melhores substitutos num raio de 30km.
    Filtra por distância e ordena por relevância (Certificações/Skills).
    """
    client = get_client()
    # Filtro OData para busca geoespacial
    odata_filter = f"geo.distance(posicao_geografica, geography'POINT({lon} {lat})') le {max_dist_km}"
    
    try:
        results = client.search(
            search_text=query,
            filter=odata_filter,
            top=5,
            select=["nome_completo", "perfil_comportamental", "certificacoes", "soft_skills", "nota_performance"]
        )
        
        docs = []
        for res in results:
            # Montamos o conteúdo que será injetado no prompt da IA (Contexto)
            content = (
                f"Vigilante: {res.get('nome_completo')}\n"
                f"Nota: {res.get('nota_performance')}\n"
                f"Certificações: {res.get('certificacoes')}\n"
                f"Skills: {res.get('soft_skills')}\n"
                f"Perfil: {res.get('perfil_comportamental')}"
            )
            docs.append(Document(page_content=content, metadata=res))
        return docs
    except Exception as e:
        print(f"Erro ao buscar substitutos: {e}")
        return []