variable "project_name" {
  description = "Short project prefix used in resource names."
  type        = string
}

variable "environment" {
  description = "Environment name (dev/stage/prod)."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "westeurope"
}

variable "address_space" {
  description = "VNet CIDR."
  type        = string
  default     = "10.20.0.0/16"
}

variable "agw_subnet_cidr" {
  description = "Application Gateway subnet CIDR."
  type        = string
  default     = "10.20.1.0/24"
}

variable "app_integration_subnet_cidr" {
  description = "App Service VNet integration subnet CIDR."
  type        = string
  default     = "10.20.2.0/24"
}

variable "db_subnet_cidr" {
  description = "PostgreSQL delegated subnet CIDR."
  type        = string
  default     = "10.20.3.0/24"
}

variable "db_admin_username" {
  description = "PostgreSQL admin username."
  type        = string
}

variable "db_admin_password" {
  description = "PostgreSQL admin password."
  type        = string
  sensitive   = true
}

variable "allowed_cidr_for_admin_access" {
  description = "Optional admin source CIDR for restricted endpoints."
  type        = string
  default     = "0.0.0.0/32"
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default = {
    owner      = "assessment"
    managed_by = "terraform"
  }
}
