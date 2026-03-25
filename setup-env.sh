#!/bin/bash

# 1. Configurações de Caminho e Identificação
TERRAFORM_DIR="./terraform"
export RG_NAME="rg-staffrag-prod"



echo "🔍 Coletando informações da infraestrutura no Azure..."

# 2. Captura de Outputs do Terraform
# Usa -chdir para garantir que o Terraform encontre o estado (.tfstate)
export SEARCH_ENDPOINT=$(terraform -chdir=$TERRAFORM_DIR output -raw azure_search_endpoint)

RAW_OPENAI=$(terraform -chdir=$TERRAFORM_DIR output -raw azure_openai_endpoint)
if [[ $RAW_OPENAI != http* ]]; then
    export AZURE_OPENAI_ENDPOINT="https://$RAW_OPENAI"
else
    export AZURE_OPENAI_ENDPOINT="$RAW_OPENAI"
fi

# Extrai apenas o nome do serviço da URL
export SEARCH_NAME=$(echo $SEARCH_ENDPOINT | sed -e 's|https://||' -e 's|.search.windows.net.*||')
export SEARCH_KEY=$(az search admin-key show --service-name srch-smart-staffing-prod2 -g $RG_NAME --query "primaryKey" -o tsv)

export FUNC_NAME=$(terraform -chdir=$TERRAFORM_DIR output -raw function_app_name)
export STG_NAME=$(terraform -chdir=$TERRAFORM_DIR output -raw storage_account_name)

# 3. Credenciais e Endpoints via Azure CLI
echo "🔑 Recuperando chaves de acesso dinâmicas..."

OPENAI_NAME=$(az cognitiveservices account list -g $RG_NAME --query "[0].name" -o tsv)
export AZURE_OPENAI_API_KEY=$(az cognitiveservices account keys list --name $OPENAI_NAME -g $RG_NAME --query "key1" -o tsv)

# URL da Function (Padrão Azure)
export GEO_FUNCTION_URL="https://${FUNC_NAME}.azurewebsites.net"

# Chave da Function (Necessária para o Skillset do Search autenticar na Function)
export GEO_FUNCTION_KEY=$(az functionapp keys list --name $FUNC_NAME -g $RG_NAME --query "functionKeys.default" -o tsv)

# Connection String do Storage (Necessária para o Indexador ler os Blobs)
export AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string --name $STG_NAME -g $RG_NAME --query connectionString -o tsv)

export AKS_NAME=$(terraform -chdir=$TERRAFORM_DIR output -raw aks_cluster_name)
export ACR_LOGIN_SERVER=$(terraform -chdir=$TERRAFORM_DIR output -raw acr_login_server)
export ACR_NAME=$(echo $ACR_LOGIN_SERVER | cut -d'.' -f1)

# 3. Coleta o Client ID da Identidade para o Workload Identity
export MANAGED_IDENTITY_CLIENT_ID=$(terraform -chdir=./terraform output -raw managed_identity_client_id)

# Verificação de segurança no terminal
if [ -z "$AZURE_STORAGE_CONNECTION_STRING" ]; then
    echo "FALHA: Não foi possível obter a Connection String do Storage."
else
    echo "Connection String configurada!"
fi

echo "📝 Gravando variáveis no arquivo .env..."
cat <<EOF > .env
SEARCH_ENDPOINT="$SEARCH_ENDPOINT"
SEARCH_KEY="$SEARCH_KEY"
AZURE_OPENAI_ENDPOINT="$AZURE_OPENAI_ENDPOINT"
AZURE_OPENAI_API_KEY="$AZURE_OPENAI_API_KEY"
OPENAI_API_VERSION="2024-02-01"
AZURE_STORAGE_CONNECTION_STRING="$AZURE_STORAGE_CONNECTION_STRING"
EOF

echo "--------------------------------------------------------"
echo "✅ AMBIENTE CONFIGURADO E .ENV ATUALIZADO!"



echo "--------------------------------------------------------"
echo "✅ AMBIENTE CONFIGURADO COM SUCESSO!"
echo "RG:         $RG_NAME"
echo "Search:     $SEARCH_ENDPOINT"
echo "OpenAI:     $AZURE_OPENAI_ENDPOINT"
echo "Function:   $FUNC_NAME"
echo "Storage:    $STG_NAME"
echo "--------------------------------------------------------"