import pytest
from langchain_core.documents import Document

@pytest.fixture
def mock_search_result():
    return {
        "nome_completo": "Vigilante Teste",
        "posicao_geografica": {"type": "Point", "coordinates": [-46.6, -23.5]},
        "certificacoes": "Vigilância Patrimonial",
        "soft_skills": "Proatividade",
        "perfil_comportamental": "Perfil calmo",
        "nota_performance": 9.0
    }

@pytest.fixture
def mock_langchain_doc(mock_search_result):
    return Document(
        page_content="Conteúdo de teste",
        metadata=mock_search_result
    )