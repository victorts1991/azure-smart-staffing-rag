# 1. Azure Container Registry (Onde ficarão as imagens da API)
resource "azurerm_container_registry" "acr" {
  name                = "acr${replace(var.project_name, "-", "")}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = false # Segurança: Acesso via Entra ID/RBAC
}

# 2. Azure Kubernetes Service (Cluster)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${var.project_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "smartstaffing"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2ds_v5" 
    zones      = []
    vnet_subnet_id = var.vnet_subnet_id
  }

  # Configuração de Identidade do Cluster
  identity {
    type = "SystemAssigned"
  }

  # Integração com a Network (Azure CNI)
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"

    # PARA EVITAR O OVERLAP:
    service_cidr       = "172.16.0.0/16"
    dns_service_ip     = "172.16.0.10"
  }

  # Habilita OIDC e Workload Identity (Crucial para o seu RAG Passwordless)
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
}

# 3. Permissão para o AKS puxar imagens do ACR (AcrPull)
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}