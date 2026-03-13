output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "aks_subnet_id" {
  value = azurerm_subnet.aks_subnet.id
}

output "ai_subnet_id" {
  value = azurerm_subnet.ai_subnet.id
}

output "func_subnet_id" {
  value = azurerm_subnet.func_subnet.id
}