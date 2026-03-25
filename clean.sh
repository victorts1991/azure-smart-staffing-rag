#!/bin/bash

echo "🚀 INICIANDO O RESET..."

# 1. REMOVE RESOURCE GROUP
echo "🛡️ Removendo ContainerInsights órfão..."
RES_ID="/subscriptions/c62b5174-c2f7-4114-a373-a94114562107/resourceGroups/rg-staffrag-prod/providers/Microsoft.OperationsManagement/solutions/ContainerInsights(law-aks-staffrag)"
az resource delete --ids "$RES_ID" 2>/dev/null || echo "Já era."

# 2. TERRAFORM DESTROY E LIMPEZA LOCAL
if [ -d "terraform" ]; then
    echo "💣 Terraform Destroy..."
    cd terraform
    terraform init -reconfigure > /dev/null 2>&1
    terraform destroy -auto-approve -var="prefix=${PREFIX:-staffrag}" || true
    rm -rf .terraform/ .terraform.lock.hcl terraform.tfstate*
    cd ..
fi

# 3. PURGE GLOBAL
echo "🧹 (Cognitive Services)..."
# Lista todos os deletados na subscrição inteira
az cognitiveservices account list-deleted --query "[].{name:name, location:location, resourceGroup:resourceGroup}" -o json | jq -c '.[]' | while read -r item; do
    NAME=$(echo $item | jq -r '.name')
    LOC=$(echo $item | jq -r '.location')
    RG=$(echo $item | jq -r '.resourceGroup')
    echo "🔥 Executando PURGE em: $NAME ($LOC)..."
    az cognitiveservices account purge --name "$NAME" --location "$LOC" --resource-group "$RG"
done

echo "🔍 Esvaziando o Azure AI Search..."
DELETED_SEARCH=$(az search service list-deleted --query "[].name" -o tsv 2>/dev/null)
for SRCH in $DELETED_SEARCH; do
    echo "🔥 Purge Search: $SRCH..."
    az search service purge --name "$SRCH" --location "eastus2"
done

# 4. DELETA OS GRUPOS
echo "📂 Deletando Resource Groups..."
az group delete --name "rg-terraform-state" --yes --no-wait 2>/dev/null
az group delete --name "rg-staffrag-prod" --yes --no-wait 2>/dev/null

# 5. LIMPEZA DE IDENTIDADES
echo "🆔 Deletando App Registrations..."
az ad app list --display-name "staffingrag" --query "[].appId" -o tsv | while read -r appid; do
    az ad app delete --id "$appid"
done

# 6. CACHES LOCAIS
echo "🐍 Limpando Caches Locais..."
find . -type d -name "__pycache__" -exec rm -rf {} +
rm -f azure.env deploy.zip
unset PREFIX ST_NAME RG_NAME AZURE_CREDENTIALS
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder

echo "✅ TUDO LIMPO. AGUARDE 2 MINUTOS PARA O CACHE DA AZURE ATUALIZAR."