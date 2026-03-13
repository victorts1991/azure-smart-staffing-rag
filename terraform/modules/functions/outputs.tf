output "function_app_name" {
  description = "O nome da Function App criada"
  value       = azurerm_linux_function_app.enrich_func.name
}

output "function_app_default_hostname" {
  description = "O endpoint padrão da Function App"
  value       = azurerm_linux_function_app.enrich_func.default_hostname
}

output "function_app_identity_principal_id" {
  description = "O Principal ID da Managed Identity da Function (útil para auditoria RBAC)"
  value       = azurerm_linux_function_app.enrich_func.identity[0].principal_id
}