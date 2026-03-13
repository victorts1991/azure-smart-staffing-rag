output "search_endpoint" {
  value = "https://${azurerm_search_service.search.name}.search.windows.net"
}

output "openai_endpoint" {
  value = azurerm_cognitive_account.openai.endpoint
}

output "search_service_name" {
  value = azurerm_search_service.search.name
}