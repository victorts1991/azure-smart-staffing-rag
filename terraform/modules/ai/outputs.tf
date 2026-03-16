output "search_endpoint" {
  value = "https://${azurerm_search_service.search.name}.search.windows.net"
}

output "openai_endpoint" {
  value = azurerm_cognitive_account.openai.endpoint
}

output "search_service_name" {
  value = azurerm_search_service.search.name
}

# ESSENCIAIS PARA O MAIN DA RAIZ:
output "openai_account_id" {
  value = azurerm_cognitive_account.openai.id
}

output "search_service_principal_id" {
  value = azurerm_search_service.search.identity[0].principal_id
}