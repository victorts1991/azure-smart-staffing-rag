variable "resource_group_name"      { type = string }
variable "location"                 { type = string }
variable "project_name"             { type = string }
variable "storage_account_name"     { type = string }
variable "storage_account_id"       { type = string }
variable "storage_account_primary_key" { type = string }
variable "storage_connection_string" { type = string }
variable "ai_search_endpoint"       { type = string }
variable "openai_endpoint"          { type = string }
variable "maps_subscription_key" {
  description = "Chave de acesso do Azure Maps"
  type        = string
  sensitive   = true
}