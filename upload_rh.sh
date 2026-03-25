#!/bin/bash

# Configurações Iniciais
PREFIX="staffrag"
RG_NAME="rg-${PREFIX}-prod"
CONTAINER_NAME="rh-uploads"
FILE_NAME="base_vigilantes_ativos.csv"

echo "🔍 Buscando informações da infraestrutura no Azure..."

# 1. Descobre o nome da Storage Account dinamicamente (filtra pelo RG)
ST_NAME=$(az storage account list -g "$RG_NAME" --query "[0].name" -o tsv)

if [ -z "$ST_NAME" ]; then
    echo "❌ ERRO: Não foi possível encontrar uma Storage Account no grupo $RG_NAME"
    exit 1
fi

echo "📦 Conta encontrada: $ST_NAME"

# 2. Recupera a Connection String para autenticação
echo "🔑 Coletando chave de acesso..."
ST_CONN=$(az storage account show-connection-string -g "$RG_NAME" -n "$ST_NAME" --query connectionString -o tsv)

# 3. Realiza o Upload
echo "🚀 Iniciando upload do arquivo $FILE_NAME..."
az storage blob upload \
  --container-name "$CONTAINER_NAME" \
  --file "$FILE_NAME" \
  --name "$FILE_NAME" \
  --connection-string "$ST_CONN" \
  --overwrite

if [ $? -eq 0 ]; then
    echo "✅ SUCESSO: Arquivo enviado para o Azure Blob Storage."
    echo "💡 O Azure AI Search iniciará a indexação em breve."
else
    echo "❌ FALHA: Ocorreu um erro durante o upload."
fi