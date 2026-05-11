variable "name_prefix" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "app_gateway_subnet_id" { type = string }
variable "frontend_load_balancer_private_ip" { type = string }
variable "backend_load_balancer_private_ip" { type = string }
variable "ssl_certificate_base64" {
  type      = string
  sensitive = true
}
variable "ssl_certificate_password" {
  type      = string
  sensitive = true
}
variable "threat_intel_block_ips" {
  type        = list(string)
  description = "Threat intelligence IP addresses or CIDR ranges blocked at the Application Gateway WAF policy."
  default     = []
}
variable "tags" { type = map(string) }
