#!/bin/bash

# 1. Configurações
PREFIX="staffingrag"
RG_STATE="rg-terraform-state"
LOCATION="eastus2"
ST_NAME="st${PREFIX}tf$(openssl rand -hex 3)"
CONTAINER="tfstate"
SP_NAME="${PREFIX}-github-actions"

echo "⏳ Verificando se o grupo $RG_STATE ainda existe..."
while [ "$(az group show --name $RG_STATE --query "properties.provisioningState" -o tsv 2>/dev/null)" == "Deleting" ]; do
    echo "Aguardando a Azure terminar de apagar o grupo antigo..."
    sleep 10
done

echo "🏁 Iniciando Bootstrap Total..."

# 2. Criar Storage para o Terraform State
echo "📦 Criando Storage para o State..."
az group create --name $RG_STATE --location $LOCATION
az storage account create \
    --resource-group $RG_STATE \
    --name $ST_NAME \
    --sku Standard_LRS \
    --encryption-services blob \
    --min-tls-version TLS1_2

echo "⏳ Aguardando 30s para propagação de DNS (Evita o erro de 'Failed to resolve')..."
sleep 30

az storage container create \
    --name $CONTAINER \
    --account-name $ST_NAME \
    --auth-mode login

# 3. Cria o Service Principal e já obtém as Credenciais
echo "🔑 Criando Service Principal e gerando credenciais..."
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Cria o SP com permissão de Contributor na Subscription e já gera o JSON
AZURE_CREDENTIALS=$(az ad sp create-for-rbac --name "$SP_NAME" --role contributor \
                    --scopes /subscriptions/$SUBSCRIPTION_ID \
                    --sdk-auth)

# Extrai o ClientID (AppID) do JSON gerado para dar a permissão de Admin
SP_APP_ID=$(echo $AZURE_CREDENTIALS | jq -r '.clientId')

echo "🛡️ Elevando permissões para 'User Access Administrator'..."
# Aguarda 15 segundos para o SP propagar no Azure AD (evita erro de ServicePrincipalNotFound)
sleep 15

az role assignment create \
    --assignee "$SP_APP_ID" \
    --role "User Access Administrator" \
    --scope "/subscriptions/$SUBSCRIPTION_ID"

# 4. Resultado Final
echo "----------------------------------------------------"
echo "✅ BOOTSTRAP CONCLUÍDO!"
echo "----------------------------------------------------"
echo "1. STORAGE NAME (Coloque no backend do main.tf):"
echo "$ST_NAME"
echo ""
echo "2. AZURE_CREDENTIALS (Copie TODO o JSON abaixo para a Secret do GitHub):"
echo "$AZURE_CREDENTIALS"
echo "----------------------------------------------------"