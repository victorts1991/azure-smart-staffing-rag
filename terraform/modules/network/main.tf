# Virtual Network principal
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-smart-staffing"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Subnet para o AKS (Onde ficará a API FastAPI)
resource "azurerm_subnet" "aks_subnet" {
  name                 = "snet-aks"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Subnet para IA e Serviços de Dados (Private Endpoints)
resource "azurerm_subnet" "ai_subnet" {
  name                 = "snet-ai-services"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  
  # Necessário para habilitar Private Endpoints
  private_endpoint_network_policies = "Enabled"
}

# Subnet para as Azure Functions (Ingestão)
resource "azurerm_subnet" "func_subnet" {
  name                 = "snet-functions"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]

  # Delegação para que a Azure Function possa se integrar à VNet
  delegation {
    name = "function-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}