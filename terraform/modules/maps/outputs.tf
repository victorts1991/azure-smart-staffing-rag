output "maps_primary_key" {
  value     = azurerm_maps_account.maps.primary_access_key
  sensitive = true
}

output "maps_account_id" {
  value = azurerm_maps_account.maps.id
}