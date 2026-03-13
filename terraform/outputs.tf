# ==============================================================================
# PROJETO: Azure Smart Staffing RAG 🛡️
# ARQUIVO: terraform/outputs.tf
# DESCRIÇÃO: Exposição dos dados da infraestrutura para o App e CI/CD.
# ==============================================================================

# --- Identidade Gerenciada ---
output "managed_identity_client_id" {
  description = "Client ID da Identidade Gerenciada (usado no código para Auth)"
  value       = azurerm_user_assigned_identity.main_id.client_id
}

# --- Inteligência Artificial (Vindos do módulo AI) ---
output "azure_search_endpoint" {
  description = "Endpoint do serviço de busca híbrida"
  value       = module.ai.search_endpoint
}

output "azure_openai_endpoint" {
  description = "Endpoint do Azure OpenAI (GPT-4o/Embeddings)"
  value       = module.ai.openai_endpoint
}

# --- Armazenamento (Vindos do módulo Storage) ---
output "storage_account_name" {
  description = "Nome da Storage Account para ingestão de CSVs"
  value       = module.storage.account_name
}

# --- Networking ---
output "vnet_id" {
  description = "ID da VNet principal"
  value       = module.network.vnet_id
}

# --- Kubernetes (Vindos do módulo AKS) ---
output "aks_cluster_name" {
  description = "Nome do Cluster AKS"
  value       = module.aks.cluster_name
}

output "acr_login_server" {
  description = "Endpoint do Container Registry para o Docker Push"
  value       = module.aks.acr_login_server
}