resource "azurerm_maps_account" "maps" {
  name                = "maps-smart-staffing"
  resource_group_name = var.resource_group_name
  location            = "global" # Azure Maps é um serviço global
  sku_name            = "G2"     # SKU que permite maior volume de requisições e recursos avançados

  tags = var.tags
}