from langchain_community.vectorstores.azuresearch import AzureSearch
from langchain_openai import AzureOpenAIEmbeddings
from app.core.config import settings, azure_credential

def get_retriever():
    # 1. Configura o gerador de Embeddings (para busca vetorial)
    embeddings = AzureOpenAIEmbeddings(
        azure_deployment=settings.AZURE_OPENAI_EMBEDDING_DEPLOYMENT,
        openai_api_version=settings.AZURE_OPENAI_API_VERSION,
        azure_endpoint=settings.OPENAI_ENDPOINT,
        credential=azure_credential
    )

    # 2. Conecta ao Azure AI Search como um Vector Store do LangChain
    vector_store = AzureSearch(
        azure_search_endpoint=settings.SEARCH_ENDPOINT,
        azure_search_key=None, # Usando Credential via Identity
        index_name=settings.SEARCH_INDEX_NAME,
        embedding_function=embeddings.embed_query,
        additional_search_client_options={"credential": azure_credential}
    )
    
    return vector_store

def search_vigilantes(query_text, lat=None, lon=None, max_dist_km=20):
    vector_store = get_retriever()
    
    # Filtro OData: Apenas vigilantes com reciclagem em dia (exemplo)
    # E filtro geográfico se lat/lon forem passados
    filters = "status_reciclagem eq 'Em dia'"
    if lat and lon:
        filters += f" and geo.distance(location, geography'POINT({lon} {lat})') le {max_dist_km}"

    # Realiza a busca híbrida
    docs = vector_store.similarity_search(
        query=query_text,
        k=5,
        filters=filters,
        search_type="hybrid"
    )
    return docs