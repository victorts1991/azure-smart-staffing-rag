import os
from azure.identity import DefaultAzureCredential
from azure.search.documents.indexes import SearchIndexClient

# Garante que as envs estão certas
endpoint = f"https://srch-smart-staffing-prod2.search.windows.net"
credential = DefaultAzureCredential()

try:
    client = SearchIndexClient(endpoint, credential)
    index = client.get_index("vigilantes-index")
    print(f"\nÍNDICE ENCONTRADO!")
    fields = [f.name for f in index.fields]
    print(f"Campos: {fields}")
    
    if "soft_skills_vector" in fields:
        print("O campo existe.")
    else:
        print("O campo NÃO existe. O erro é no Index.")
except Exception as e:
    print(f"Erro: {e}")