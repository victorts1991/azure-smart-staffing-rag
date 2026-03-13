# Gerador de sufixo aleatório para unicidade do nome
resource "random_id" "st_id" {
  byte_length = 4
}

resource "azurerm_storage_account" "st" {
  name                     = "stsmartstaffing${lower(random_id.st_id.hex)}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Segurança: Força HTTPS e TLS 1.2 conforme as boas práticas
  https_traffic_only_enabled = true
  min_tls_version           = "TLS1_2"
  
  # Desabilita o acesso público para maior segurança
  public_network_access_enabled = true # Pode ser alterado para false se usar Private Endpoints
}

# Container onde os CSVs serão depositados (rh-uploads)
resource "azurerm_storage_container" "container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.st.name
  container_access_type = "private"
}

# --- ATRIBUIÇÃO DE RBAC (Zero Trust) ---
# Permite que a Managed Identity principal tenha acesso de leitura/escrita aos blobs
resource "azurerm_role_assignment" "st_role" {
  scope                = azurerm_storage_account.st.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.principal_id
}