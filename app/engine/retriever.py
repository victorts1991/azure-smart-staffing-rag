import os
from azure.identity import DefaultAzureCredential
from azure.search.documents import SearchClient
from langchain_core.documents import Document

def get_client():
    endpoint = os.getenv("SEARCH_ENDPOINT")
    credential = DefaultAzureCredential()
    return SearchClient(endpoint=endpoint, index_name="vigilantes-index", credential=credential)

def get_staff_retriever(lat, lon, query, max_dist_km=50):
    client = get_client()
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
        print(f"❌ Erro Azure: {e}")
        return []

def get_missing_staff_data(nome_faltante: str):
    client = get_client()
    # Busca exata ou aproximada pelo nome
    results = client.search(
        search_text=nome_faltante,
        select=["nome_completo", "posicao_geografica", "certificacoes", "soft_skills"],
        top=1
    )
    
    for res in results:
        return res # Retorna o primeiro match
    return None