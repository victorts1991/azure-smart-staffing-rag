# ==============================================================================
# PROJETO: Azure Smart Staffing RAG 🛡️
# ARQUIVO: terraform/variables.tf
# DESCRIÇÃO: Definição de variáveis globais do projeto.
# ==============================================================================

variable "project_name" {
  description = "Nome base do projeto para prefixo de recursos"
  type        = string
  default     = "smart-staffing"
}

variable "location" {
  description = "Região da Azure onde os recursos serão provisionados"
  type        = string
  default     = "eastus2"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "prod"
}

# --- Variáveis de Networking ---

variable "vnet_address_space" {
  description = "Espaço de endereçamento da VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

# --- Variáveis de IA ---

variable "gpt_model_name" {
  description = "Nome do modelo GPT no Azure OpenAI"
  type        = string
  default     = "gpt-4o"
}

variable "embedding_model_name" {
  description = "Nome do modelo de Embedding no Azure OpenAI"
  type        = string
  default     = "text-embedding-3-small"
}

# --- Variáveis de Tags ---

variable "tags" {
  description = "Tags básicas para organização de custos"
  type        = map(string)
  default     = {
    Project   = "SmartStaffingRAG"
    ManagedBy = "Terraform"
    Owner     = "DataEngineering"
  }
}

variable "prefix" {
  type        = string
  description = "Prefixo único para os recursos da Azure"
  default     = "staffrag" 
}