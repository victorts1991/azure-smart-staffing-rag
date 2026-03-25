import os
import json
import sys
from azure.identity import DefaultAzureCredential
from azure.search.documents.indexes import SearchIndexClient, SearchIndexerClient
from azure.search.documents.indexes.models import (
    SearchIndexerDataSourceConnection,
    SearchIndexerDataContainer,
    SearchIndex,
    SearchIndexer, 
    SearchIndexerSkillset,
    FieldMapping,
    HighWaterMarkChangeDetectionPolicy,
    IndexingSchedule,
    
)

def load_asset(name, replacements=None):
    filepath = f"search_assets/{name}.json"
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()
        if replacements:
            for key, value in replacements.items():
                content = content.replace(f"<{key}>", value)
        return json.loads(content)

def setup_datasource(idr_client):
    connection_string = os.environ.get("AZURE_STORAGE_CONNECTION_STRING")
    if not connection_string:
        print("Erro: AZURE_STORAGE_CONNECTION_STRING não configurada.")
        sys.exit(1)

    ds_connection = SearchIndexerDataSourceConnection(
        name="vigilantes-blob-ds",
        type="azureblob",
        connection_string=connection_string,
        container=SearchIndexerDataContainer(name="rh-uploads"),
        data_change_detection_policy=HighWaterMarkChangeDetectionPolicy(
            high_water_mark_column_name="metadata_storage_last_modified"
        )
    )
    idr_client.create_or_update_data_source_connection(ds_connection)

def sync():
    endpoint = os.environ.get("SEARCH_ENDPOINT")
    replacements = {
        "AZURE_OPENAI_ENDPOINT": os.environ.get("AZURE_OPENAI_ENDPOINT"),
        "GEO_FUNCTION_URL": os.environ.get("GEO_FUNCTION_URL"),
        "GEO_FUNCTION_KEY": os.environ.get("GEO_FUNCTION_KEY")
    }

    credential = DefaultAzureCredential()
    idx_client = SearchIndexClient(endpoint, credential)
    idr_client = SearchIndexerClient(endpoint, credential)

    setup_datasource(idr_client)

    # A. Índice
    index_data = load_asset("index")
    idx_client.create_or_update_index(SearchIndex.from_dict(index_data))
    
    # B. Skillset
    skillset_data = load_asset("skillset", replacements)
    idr_client.create_or_update_skillset(SearchIndexerSkillset.from_dict(skillset_data))
    
    # C. Indexador 
    indexer_data = load_asset("indexer")
    
    # CONVERSÃO OBRIGATÓRIA PARA O SDK FUNCIONAR
    f_mappings = [FieldMapping(source_field_name=m["sourceFieldName"], target_field_name=m["targetFieldName"]) 
                  for m in indexer_data.get("fieldMappings", [])]
    
    o_mappings = [FieldMapping(source_field_name=m["sourceFieldName"], target_field_name=m["targetFieldName"]) 
                  for m in indexer_data.get("outputFieldMappings", [])]

    indexer_obj = SearchIndexer(
        name=indexer_data["name"],
        data_source_name=indexer_data["dataSourceName"],
        target_index_name=indexer_data["targetIndexName"],
        skillset_name=indexer_data.get("skillsetName"),
        field_mappings=f_mappings,
        output_field_mappings=o_mappings,
        parameters=indexer_data.get("parameters"),
        schedule=IndexingSchedule(interval=indexer_data["schedule"]["interval"])
    )
    
    idr_client.create_or_update_indexer(indexer_obj)
    print("\nSincronização concluída!")

if __name__ == "__main__":
    sync()