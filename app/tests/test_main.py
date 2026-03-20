from fastapi.testclient import TestClient
from app.main import app
from unittest.mock import patch

client = TestClient(app)

def test_find_replacement_404_when_user_not_found():
    """Valida 404 quando o vigilante não passa na validação de identidade"""
    with patch('app.main.get_missing_staff_data', return_value=None):
        response = client.post("/v1/find-replacement", json={"nome": "Inexistente"})
        assert response.status_code == 404
        assert "não encontrado" in response.json()["detail"]

def test_find_replacement_400_invalid_gps():
    """Valida 400 quando o vigilante não possui coordenadas geográficas"""
    mock_data = {"nome_completo": "Sem GPS", "posicao_geografica": None}
    with patch('app.main.get_missing_staff_data', return_value=mock_data):
        response = client.post("/v1/find-replacement", json={"nome": "Sem GPS"})
        assert response.status_code == 400
        assert "coordenadas GPS" in response.json()["detail"]

@patch('app.main.get_justification_chain')
@patch('app.main.get_staff_retriever')
@patch('app.main.get_missing_staff_data')
def test_find_replacement_full_success(mock_missing, mock_retriever, mock_chain, mock_langchain_doc):
    """Testa o fluxo completo de sucesso da API"""
    mock_missing.return_value = {
        "nome_completo": "Francisco Barros", 
        "posicao_geografica": {"coordinates": [-46.6, -23.5]},
        "certificacoes": "VSPP"
    }
    
    # Simula o retorno de um candidato diferente do faltante
    mock_retriever.return_value = [mock_langchain_doc] 
    mock_chain.return_value = "Justificativa gerada pela IA"

    payload = {"nome": "Francisco Barros", "perfil_extra": "Hospital"}
    response = client.post("/v1/find-replacement", json=payload)
    
    json_response = response.json()
    
    assert response.status_code == 200
    assert json_response["status"] == "Processado com Sucesso"
    assert "decisao_do_coordenador_ia" in json_response