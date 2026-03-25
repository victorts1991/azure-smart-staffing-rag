# 0. Gerador de Sufixo Aleatório (O "Vacina" contra o Erro 409)
resource "random_id" "suffix" {
  byte_length = 2 # Gera 4 caracteres hexadecimais (ex: 4f2a)
}

# 1. Azure OpenAI Service
resource "azurerm_cognitive_account" "openai" {
  name                = "cog-smart-staffing-${random_id.suffix.hex}"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "OpenAI"
  sku_name            = "S0"

  # Permite que o serviço use Managed Identity (importante para logs e auditoria)
  identity {
    type = "SystemAssigned"
  }

  # SUBDOMÍNIO DINÂMICO: Obrigatório ser único na Azure inteira
  custom_subdomain_name = "smart-staffing-openai-${random_id.suffix.hex}"
}

# Deployment do GPT-4o (Justificativa e Raciocínio)
resource "azurerm_cognitive_deployment" "gpt4o" {
  name                 = "gpt-4o"
  cognitive_account_id = azurerm_cognitive_account.openai.id
  
  model {
    format  = "OpenAI"
    name    = "gpt-4o"
    version = "2024-05-13"
  }

  scale {
    type     = "Standard"
    capacity = 10
  }
}

# Deployment do Text-Embeddings (Transforma soft skills em vetores)
resource "azurerm_cognitive_deployment" "embeddings" {
  name                 = "text-embedding-3-small"
  cognitive_account_id = azurerm_cognitive_account.openai.id
  
  model {
    format  = "OpenAI"
    name    = "text-embedding-3-small"
    version = "1" # Versão padrão do modelo de embedding
  }

  scale {
    type     = "Standard"
    capacity = 20
  }
}

# 2. Azure AI Search (O motor de busca RAG)
resource "azurerm_search_service" "search" {
  name                = "srch-smart-staffing-${random_id.suffix.hex}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "standard" # Essencial para Hybrid Search e Geolocation

  # Habilita o ranking semântico (L2 Re-ranking) que você citou no Roadmap
  semantic_search_sku = "free"

  # Configuração Zero Trust: desabilita chaves de admin (usa apenas RBAC)
  local_authentication_enabled = false

  identity {
    type = "SystemAssigned"
  }

  # (Isso ajuda em cenários onde o Search precisa de Managed Identity para acessar o Blob)
  public_network_access_enabled = true
}

# 3. RBAC: Permite que a Managed Identity da App consulte o Search
resource "azurerm_role_assignment" "search_index_reader" {
  scope                = azurerm_search_service.search.id
  role_definition_name = "Search Index Data Reader"
  principal_id         = var.principal_id
}

# 4. RBAC: Permite que a Managed Identity da App use o OpenAI
resource "azurerm_role_assignment" "openai_user" {
  scope                = azurerm_cognitive_account.openai.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = var.principal_id
}