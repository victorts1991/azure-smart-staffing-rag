variable "resource_group_name" {
  description = "Nome do grupo de recursos"
  type        = string
}

variable "location" {
  description = "Região da Azure"
  type        = string
  default     = "brazilsouth"
}

variable "tags" {
  description = "Tags para o recurso"
  type        = map(string)
  default     = {}
}