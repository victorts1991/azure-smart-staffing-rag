output "account_name" {
  description = "O nome da Storage Account criada"
  value       = azurerm_storage_account.st.name
}

output "account_id" {
  description = "O ID da Storage Account"
  value       = azurerm_storage_account.st.id
}

output "primary_blob_endpoint" {
  description = "Endpoint para acesso aos blobs"
  value       = azurerm_storage_account.st.primary_blob_endpoint
}

output "primary_access_key"        { value = azurerm_storage_account.st.primary_access_key }
output "primary_connection_string" { value = azurerm_storage_account.st.primary_connection_string }