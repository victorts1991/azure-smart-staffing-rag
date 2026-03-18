from fastapi import FastAPI, HTTPException
from app.engine.retriever import search_vigilantes
from pydantic import BaseModel

app = FastAPI(title="Azure Smart Staffing RAG API")

class SearchRequest(BaseModel):
    perfil_desejado: str
    cep: str = None
    distancia_km: int = 20

@app.get("/")
def read_root():
    return {"status": "online", "engine": "RAG Smart Staffing"}

@app.post("/buscar-candidatos")
async def buscar(payload: SearchRequest):
    try:
        
        candidatos = search_vigilantes(
            query_text=payload.perfil_desejado,
            max_dist_km=payload.distancia_km
        )
        
        return {"total": len(candidatos), "data": candidatos}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))