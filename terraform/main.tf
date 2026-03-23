# ==============================================================================
# PROJETO: Azure Smart Staffing RAG 🛡️
# ARQUIVO: terraform/main.tf
# DESCRIÇÃO: Orquestrador principal da infraestrutura.
# ==============================================================================

# 1. Configuração do Backend Remoto (Blob Storage criado no Bootstrap)
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "ststaffingragtf5d3268"
    container_name       = "tfstate"
    key                  = "smart-staffing.terraform.tfstate"
    }
}

provider "azurerm" {
  features {}
}

# 2. Grupo de Recursos Principal do Projeto
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.prefix}-prod"
  location = "eastus2" 
}

# 3. Identidade Gerenciada Única (Zero Trust)
# Esta identidade será usada pelo AKS e pelas Azure Functions para acesso passwordless
resource "azurerm_user_assigned_identity" "main_id" {
  name                = "id-${var.prefix}-prod"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# 4. Módulo de Networking (VNet e Isolamento)
module "network" {
  source              = "./modules/network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# 5. NOVO: Módulo de Azure Maps
module "maps" {
  source              = "./modules/maps"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# 6. Módulo de Inteligência Artificial (OpenAI & AI Search)
module "ai" {
  source              = "./modules/ai"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  # Integrando com a identidade para permitir que o Search acesse o OpenAI se necessário
  principal_id        = azurerm_user_assigned_identity.main_id.principal_id
}

# 7. Módulo de Storage (Camada de Ingestão do RH)
module "storage" {
  source              = "./modules/storage"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  container_name      = "rh-uploads"
  
  # RBAC: Permite que a Managed Identity leia os CSVs gerados pelo seu script
  principal_id        = azurerm_user_assigned_identity.main_id.principal_id
}

# 8. Módulo de Compute (AKS - Onde rodará o FastAPI)
module "aks" {
  source              = "./modules/aks"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  project_name = var.prefix
  
  # Rede e Segurança
  vnet_subnet_id      = module.network.aks_subnet_id
  identity_id         = azurerm_user_assigned_identity.main_id.id
  principal_id        = azurerm_user_assigned_identity.main_id.principal_id
  
}

# 9. Módulo de Functions
module "functions" {
  source                     = "./modules/functions"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  project_name = var.prefix
  
  storage_account_name       = module.storage.account_name
  storage_account_id         = module.storage.account_id
  storage_account_primary_key = module.storage.primary_access_key
  storage_connection_string  = module.storage.primary_connection_string
  
  ai_search_endpoint         = module.ai.search_endpoint
  openai_endpoint            = module.ai.openai_endpoint

  maps_subscription_key        = module.maps.maps_primary_key
}

# 10. CONFIGURAÇÃO DE RBAC (PERMISSÕES DE ACESSO)
# Estas permissões permitem que o AI Search use a Managed Identity para falar 
# com o OpenAI e o Azure Maps sem precisar de chaves expostas.

# Permissão para o AI Search gerar vetores (Embeddings) no OpenAI
resource "azurerm_role_assignment" "search_to_openai" {
  scope                = module.ai.openai_account_id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = module.ai.search_service_principal_id
}

# Permissão para o AI Search ler dados do Azure Maps (Geocodificação)
resource "azurerm_role_assignment" "search_to_maps" {
  scope                = module.maps.maps_account_id
  role_definition_name = "Azure Maps Data Reader"
  principal_id         = module.ai.search_service_principal_id
}

# --- OUTPUTS PARA O GITHUB ACTIONS / APP ---

output "AZURE_MAPS_KEY" {
  value     = module.maps.maps_primary_key
  sensitive = true
}

output "AZURE_SEARCH_ENDPOINT" {
  value = module.ai.search_endpoint
}

output "AZURE_OPENAI_ENDPOINT" {
  value = module.ai.openai_endpoint
}

output "STORAGE_ACCOUNT_NAME" {
  value = module.storage.account_name
}

output "MANAGED_IDENTITY_CLIENT_ID" {
  value = azurerm_user_assigned_identity.main_id.client_id
}