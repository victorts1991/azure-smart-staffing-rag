# 1. Plano de Consumo (Pay-as-you-go - super barato)
resource "azurerm_service_plan" "func_plan" {
  name                = "plan-smart-staffing-functions"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "B1"
}

# 2. A Function App (Onde o código Python vai rodar)
resource "azurerm_linux_function_app" "enrich_func" {
  name                = "func-enrich-data-${var.project_name}"
  resource_group_name = var.resource_group_name
  location            = var.location

  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_primary_key
  service_plan_id            = azurerm_service_plan.func_plan.id

  public_network_access_enabled = true

  site_config {
    application_stack {
      python_version = "3.11" # Versão estável para o RAG
    }

    always_on = true
  }

  # Variáveis de Ambiente (Conecta a Função aos outros serviços)
  app_settings = {
    "AzureWebJobsStorage"      = var.storage_connection_string
    "STORAGE_ACCOUNT_NAME"     = var.storage_account_name
    "AI_SEARCH_ENDPOINT"       = var.ai_search_endpoint
    "OPENAI_ENDPOINT"          = var.openai_endpoint
    "PROJECT_NAME"             = var.project_name
  }

  identity {
    type = "SystemAssigned"
  }
}

# 3. Permissão para a Function ler o Blob Storage
resource "azurerm_role_assignment" "func_storage_read" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_function_app.enrich_func.identity[0].principal_id
}