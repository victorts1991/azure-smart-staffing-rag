variable "resource_group_name" {
  type        = string
  description = "Nome do grupo de recursos"
}

variable "location" {
  type        = string
  description = "Localização geográfica"
}

variable "container_name" {
  type        = string
  description = "Nome do container de uploads"
  default     = "rh-uploads"
}

variable "principal_id" {
  type        = string
  description = "ID da Managed Identity que terá acesso ao storage"
}