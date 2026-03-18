#!/bin/bash

# Carrega as variáveis de ambiente (Certifique-se que o RG_NAME e SEARCH_NAME estão lá)
source setup-env.sh

echo "---------------------------------------------------------"
echo "🔐 PASSO 1: Autenticação e Permissão de Dados (RBAC)"
echo "---------------------------------------------------------"

# 1. Garanta que está logado
az login

# 2. Atribui a permissão de leitura de dados do índice para o seu usuário logado
echo "⚙️ Atribuindo papel 'Search Index Data Reader'..."
USER_ID=$(az ad signed-in-user show --query id -o tsv)
SEARCH_ID=$(az search service show --name srch-smart-staffing-prod2 --resource-group $RG_NAME --query id -o tsv)

az role assignment create \
    --role "Search Index Data Reader" \
    --assignee-object-id $USER_ID \
    --scope $SEARCH_ID \
    --assignee-principal-type User

echo ""
echo "⏳ AGUARDANDO 2 MINUTOS..."
echo "O Azure precisa propagar a nova permissão pelo Active Directory."
echo "Pode tomar um café ☕, eu aviso quando terminar."
sleep 120

echo "---------------------------------------------------------"
echo "🚀 PASSO 2: Teste de Recuperação de Dados"
echo "---------------------------------------------------------"

# 3. Pega o Token de Acesso (Bearer) atualizado com a nova permissão
echo "🎫 Gerando Access Token..."
AZ_TOKEN=$(az account get-access-token --resource https://search.azure.com --query accessToken -o tsv)

# 4. Executa o curl cru para validar os dados no índice
echo "📡 Consultando o Índice 'vigilantes-index'..."
curl -v -X GET "https://srch-smart-staffing-prod2.search.windows.net/indexes/vigilantes-index/docs/\$count?api-version=2024-03-01-Preview" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $AZ_TOKEN"

echo ""
echo "---------------------------------------------------------"
echo "✅ Validação Concluída!"