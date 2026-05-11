variable "project" {
  type        = string
  description = "Project name used in resource names."
  default     = "secureflow"
}

variable "resource_group_name" {
  type        = string
  description = "Existing Azure resource group that already contains the ops VM."
  default     = "group1_final"
}

variable "vnet_name" {
  type        = string
  description = "Existing VNet that contains the ops VM."
  default     = "group1-final-vnet"
}

variable "environment" {
  type        = string
  description = "Environment name."
  default     = "dev"
}

variable "location" {
  type        = string
  description = "Azure region."
  default     = "swedencentral"
}

variable "admin_username" {
  type        = string
  description = "Linux VM administrator username."
  default     = "azureuser"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for private VM access from ops subnet or Bastion."
}

variable "sql_admin_login" {
  type        = string
  description = "Azure SQL administrator login."
  default     = "secureflowadmin"
}

variable "sql_admin_password" {
  type        = string
  description = "Azure SQL administrator password. Store this in GitHub Actions secrets or Key Vault."
  sensitive   = true
}

variable "alert_email" {
  type        = string
  description = "Email address for Azure Monitor action group."
}

variable "key_vault_admin_object_id" {
  type        = string
  description = "Azure AD object ID granted Key Vault Administrator for demo secret management."
  default     = "c18c6b19-6b8b-43eb-a9cd-2afa005b01e4"
}

variable "monthly_budget_amount" {
  type        = number
  description = "Monthly Azure Cost Management budget amount for the project resource group."
  default     = 20
}

variable "budget_start_date" {
  type        = string
  description = "Budget start date in RFC3339 format. Use the first day of the active billing month."
  default     = "2026-05-01T00:00:00Z"
}

variable "frontend_load_balancer_private_ip" {
  type        = string
  description = "Static private IP for the frontend internal load balancer."
  default     = "10.2.2.10"
}

variable "backend_load_balancer_private_ip" {
  type        = string
  description = "Static private IP for the backend internal load balancer."
  default     = "10.2.3.10"
}

variable "appgw_ssl_certificate_base64" {
  type        = string
  description = "Base64-encoded PFX certificate for HTTPS listener."
  sensitive   = true
}

variable "appgw_ssl_certificate_password" {
  type        = string
  description = "Password for the Application Gateway PFX certificate."
  sensitive   = true
}

variable "threat_intel_block_ips" {
  type        = list(string)
  description = "Threat intelligence IP addresses or CIDR ranges blocked by the Application Gateway WAF policy."
  default = [
    "162.243.103.246",
    "178.62.3.223",
    "27.133.154.218",
    "34.204.119.63",
    "50.16.16.211",
    "1.10.16.0/20",
    "1.19.0.0/16",
    "1.32.128.0/18"
  ]
}
