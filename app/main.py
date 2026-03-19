import os
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional
from dotenv import load_dotenv

# Importa as funções que criamos nos outros arquivos
from app.engine.retriever import get_staff_retriever, get_missing_staff_data
from app.engine.chain import get_justification_chain

# Carrega as variáveis (SEARCH_ENDPOINT, OPENAI_KEY, etc.)
load_dotenv()

app = FastAPI(title="Azure Smart Staffing RAG")

# DEFINIÇÃO DO SCHEMA (O segredo do erro 422/500 está aqui)
class ReplacementRequest(BaseModel):
    nome: str  # Deve ser IGUAL à chave do JSON no Postman
    perfil_extra: Optional[str] = "Vigilante padrão para posto bancário"

@app.post("/v1/find-replacement")
async def find_replacement(request: ReplacementRequest):
    # 1. Identifica quem é o colaborador ausente
    alvo = request.nome
    print(f"🚀 Iniciando busca de substituto para: {alvo}")

    # 2. Busca os dados geográficos e técnicos do faltante no Azure
    faltante_data = get_missing_staff_data(alvo)
    
    if not faltante_data:
        raise HTTPException(status_code=404, detail=f"Vigilante '{alvo}' não encontrado no banco de dados.")

    # 3. Extrai as coordenadas do "vigilante" para buscar vizinhos
    pos = faltante_data.get("posicao_geografica")
    if not pos or "coordinates" not in pos:
        raise HTTPException(status_code=400, detail="Colaborador sem coordenadas GPS válidas.")
    
    lon, lat = pos["coordinates"]

    # 4. Busca candidatos num raio de 30km da casa/posto do faltante
    # A query combina o que o faltante já fazia com o que você pediu a mais
    query_tecnica = f"{faltante_data.get('certificacoes')} {request.perfil_extra}"
    candidatos = get_staff_retriever(lat, lon, query_tecnica, max_dist_km=30)

    # 5. Limpeza: remove o próprio faltante da lista de sugestões
    candidatos_filtrados = [c for c in candidatos if c.metadata['nome_completo'] != alvo]

    if not candidatos_filtrados:
        return {
            "faltante": alvo,
            "mensagem": "Busca concluída: nenhum substituto qualificado num raio de 30km."
        }

    # 6. O CÉREBRO: A IA analisa a lista e escreve a justificativa real
    print(f"🧠 Enviando {len(candidatos_filtrados)} candidatos para análise da IA...")
    analise_final = get_justification_chain(
        alvo, 
        request.perfil_extra, 
        candidatos_filtrados
    )

    # 7. RETORNO FINAL
    return {
        "status": "Processado com Sucesso",
        "faltante": alvo,
        "decisao_do_coordenador_ia": analise_final,
        "ranking_proximidade": [c.metadata['nome_completo'] for c in candidatos_filtrados]
    }