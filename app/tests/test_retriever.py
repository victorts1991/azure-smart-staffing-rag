from unittest.mock import MagicMock, patch
from app.engine.retriever import get_missing_staff_data, get_staff_retriever

@patch('app.engine.retriever.get_client')
def test_get_missing_staff_data_success(mock_get_client, mock_search_result):
    """Testa se encontra o vigilante quando o nome é exato"""
    mock_client = MagicMock()
    mock_client.search.return_value = [mock_search_result]
    mock_get_client.return_value = mock_client

    result = get_missing_staff_data("Vigilante Teste")

    assert result["nome_completo"] == "Vigilante Teste"

@patch('app.engine.retriever.get_client')
def test_get_missing_staff_data_fuzzy_success(mock_get_client):
    """Garante que 'Henri' encontre 'Henry' (Fuzzy Match)"""
    mock_client = MagicMock()
    mock_client.search.return_value = [{"nome_completo": "Henry Gabriel Moura"}]
    mock_get_client.return_value = mock_client

    result = get_missing_staff_data("Henri Gabriel Moura")

    assert result is not None
    assert result["nome_completo"] == "Henry Gabriel Moura"

@patch('app.engine.retriever.get_client')
def test_get_missing_staff_data_impostor_blocked(mock_get_client):
    """Garante que 'Ue da Silva' seja bloqueado mesmo se o Azure sugerir 'Dante Silva'"""
    mock_client = MagicMock()
    mock_client.search.return_value = [{"nome_completo": "Dante Silva"}]
    mock_get_client.return_value = mock_client

    # A similaridade entre 'Ue da Silva' e 'Dante Silva' é baixa (~0.45)
    result = get_missing_staff_data("Ue da Silva")

    assert result is None

@patch('app.engine.retriever.get_client')
def test_get_staff_retriever_empty_on_error(mock_get_client):
    """Garante que retorna lista vazia em caso de erro na Azure"""
    mock_client = MagicMock()
    mock_client.search.side_effect = Exception("Connection Error")
    mock_get_client.return_value = mock_client

    docs = get_staff_retriever(-23.5, -46.6, "query")

    assert docs == []