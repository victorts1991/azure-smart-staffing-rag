from pydantic_settings import BaseSettings
from azure.identity import DefaultAzureCredential

class Settings(BaseSettings):
    # O Pydantic lê as variáveis de ambiente
    SEARCH_ENDPOINT: str
    OPENAI_ENDPOINT: str
    
    # Nomes dos deployments definidos no Azure OpenAI
    AZURE_OPENAI_API_VERSION: str = "2024-02-01"
    AZURE_OPENAI_CHAT_DEPLOYMENT: str = "gpt-4o"
    AZURE_OPENAI_EMBEDDING_DEPLOYMENT: str = "text-embedding-3-small"
    
    # Nome do índice que o sync_search.py criou
    SEARCH_INDEX_NAME: str = "vigilantes-index"

settings = Settings()

azure_credential = DefaultAzureCredential()