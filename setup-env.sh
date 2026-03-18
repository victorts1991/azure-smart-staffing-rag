#!/bin/bash

# 1. Configurações de Caminho e Identificação
TERRAFORM_DIR="./terraform"
export RG_NAME="rg-smart-staffing-prod"

echo "🔍 Coletando informações da infraestrutura no Azure..."

# 2. Captura de Outputs do Terraform
# Usa -chdir para garantir que o Terraform encontre o estado (.tfstate)
export SEARCH_ENDPOINT=$(terraform -chdir=$TERRAFORM_DIR output -raw azure_search_endpoint)
# Extrai apenas o nome do serviço da URL
export SEARCH_NAME=$(echo $SEARCH_ENDPOINT | sed -e 's|https://||' -e 's|.search.windows.net.*||')
export SEARCH_KEY=$(az search admin-key show --service-name srch-smart-staffing-prod2 -g $RG_NAME --query "primaryKey" -o tsv)
export OPENAI_ENDPOINT=$(terraform -chdir=$TERRAFORM_DIR output -raw azure_openai_endpoint)
export FUNC_NAME=$(terraform -chdir=$TERRAFORM_DIR output -raw function_app_name)
export STG_NAME=$(terraform -chdir=$TERRAFORM_DIR output -raw storage_account_name)

# 3. Credenciais e Endpoints via Azure CLI
echo "🔑 Recuperando chaves de acesso dinâmicas..."

# URL da Function (Padrão Azure)
export GEO_FUNCTION_URL="https://${FUNC_NAME}.azurewebsites.net"

# Chave da Function (Necessária para o Skillset do Search autenticar na Function)
export GEO_FUNCTION_KEY=$(az functionapp keys list --name $FUNC_NAME -g $RG_NAME --query "functionKeys.default" -o tsv)

# Connection String do Storage (Necessária para o Indexador ler os Blobs)
export AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string --name $STG_NAME -g $RG_NAME --query connectionString -o tsv)

# Verificação de segurança no terminal
if [ -z "$AZURE_STORAGE_CONNECTION_STRING" ]; then
    echo "FALHA: Não foi possível obter a Connection String do Storage."
else
    echo "Connection String configurada!"
fi

echo "--------------------------------------------------------"
echo "✅ AMBIENTE CONFIGURADO COM SUCESSO!"
echo "RG:         $RG_NAME"
echo "Search:     $SEARCH_ENDPOINT"
echo "OpenAI:     $OPENAI_ENDPOINT"
echo "Function:   $FUNC_NAME"
echo "Storage:    $STG_NAME"
echo "--------------------------------------------------------"