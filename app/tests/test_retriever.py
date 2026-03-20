from unittest.mock import MagicMock, patch
from app.engine.retriever import get_missing_staff_data, get_staff_retriever

@patch('app.engine.retriever.get_client')
def test_get_missing_staff_data_success(mock_get_client, mock_search_result):
    # Configura o mock do SearchClient
    mock_client = MagicMock()
    mock_client.search.return_value = [mock_search_result]
    mock_get_client.return_value = mock_client

    result = get_missing_staff_data("Vigilante Teste")

    assert result["nome_completo"] == "Vigilante Teste"
    mock_client.search.assert_called_once()

@patch('app.engine.retriever.get_client')
def test_get_staff_retriever_empty_on_error(mock_get_client):
    # Simula um erro de conexão com a Azure
    mock_client = MagicMock()
    mock_client.search.side_effect = Exception("Connection Error")
    mock_get_client.return_value = mock_client

    docs = get_staff_retriever(-23.5, -46.6, "query", max_dist_km=30)

    assert docs == []