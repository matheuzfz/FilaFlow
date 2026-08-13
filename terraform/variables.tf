# ==============================================================================
# Variables Configuration - FilaFlow Infrastructure
# ==============================================================================

variable "aws_region" {
  description = "Região da AWS onde os recursos serão implantados."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente de implantação (ex: dev, staging, prod)."
  type        = string
  default     = "prod"
}

variable "app_name" {
  description = "Nome da aplicação utilizado para nomenclatura e tags."
  type        = string
  default     = "filaflow"
}
