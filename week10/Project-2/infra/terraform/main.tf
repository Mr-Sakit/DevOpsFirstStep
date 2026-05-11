locals {
  name_prefix = "${var.project}-${var.environment}"
  tags = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.main.name
}

data "azurerm_client_config" "current" {}

module "network" {
  source              = "./modules/network"
  name_prefix         = local.name_prefix
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  vnet_name           = data.azurerm_virtual_network.main.name
  tags                = local.tags
}

module "database" {
  source              = "./modules/database"
  name_prefix         = local.name_prefix
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  subnet_id           = module.network.data_subnet_id
  vnet_id             = data.azurerm_virtual_network.main.id
  sql_admin_login     = var.sql_admin_login
  sql_admin_password  = var.sql_admin_password
  tags                = local.tags
}

module "load_balancer" {
  source              = "./modules/load_balancer"
  name_prefix         = local.name_prefix
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  web_subnet_id       = module.network.web_subnet_id
  api_subnet_id       = module.network.api_subnet_id
  frontend_private_ip = var.frontend_load_balancer_private_ip
  backend_private_ip  = var.backend_load_balancer_private_ip
  tags                = local.tags
}

module "app_gateway" {
  source                            = "./modules/app_gateway"
  name_prefix                       = local.name_prefix
  location                          = data.azurerm_resource_group.main.location
  resource_group_name               = data.azurerm_resource_group.main.name
  app_gateway_subnet_id             = module.network.app_gateway_subnet_id
  frontend_load_balancer_private_ip = module.load_balancer.frontend_lb_private_ip
  backend_load_balancer_private_ip  = module.load_balancer.backend_lb_private_ip
  ssl_certificate_base64            = var.appgw_ssl_certificate_base64
  ssl_certificate_password          = var.appgw_ssl_certificate_password
  threat_intel_block_ips            = var.threat_intel_block_ips
  tags                              = local.tags
}

module "compute" {
  source                      = "./modules/compute"
  name_prefix                 = local.name_prefix
  location                    = data.azurerm_resource_group.main.location
  resource_group_name         = data.azurerm_resource_group.main.name
  frontend_subnet_id          = module.network.web_subnet_id
  backend_subnet_id           = module.network.api_subnet_id
  frontend_lb_backend_pool_id = module.load_balancer.frontend_backend_pool_id
  backend_lb_backend_pool_id  = module.load_balancer.backend_backend_pool_id
  admin_username              = var.admin_username
  ssh_public_key              = var.ssh_public_key
  tags                        = local.tags
}

module "bastion" {
  source              = "./modules/bastion"
  name                = "${var.vnet_name}-bastion"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  vnet_name           = data.azurerm_virtual_network.main.name
  tags                = local.tags
}

module "key_vault" {
  source                         = "./modules/key_vault"
  name_prefix                    = local.name_prefix
  location                       = data.azurerm_resource_group.main.location
  resource_group_name            = data.azurerm_resource_group.main.name
  resource_group_id              = data.azurerm_resource_group.main.id
  tenant_id                      = data.azurerm_client_config.current.tenant_id
  current_user_object_id         = var.key_vault_admin_object_id
  subnet_id                      = module.network.data_subnet_id
  vnet_id                        = data.azurerm_virtual_network.main.id
  frontend_identity_principal_id = module.compute.frontend_identity_principal_id
  backend_identity_principal_id  = module.compute.backend_identity_principal_id
  tags                           = local.tags
}

module "monitoring" {
  source                = "./modules/monitoring"
  name_prefix           = local.name_prefix
  location              = data.azurerm_resource_group.main.location
  resource_group_name   = data.azurerm_resource_group.main.name
  resource_group_id     = data.azurerm_resource_group.main.id
  action_email          = var.alert_email
  monthly_budget_amount = var.monthly_budget_amount
  budget_start_date     = var.budget_start_date
  app_gateway_id        = module.app_gateway.app_gateway_id
  frontend_vm_id        = module.compute.frontend_vmss_id
  backend_vm_id         = module.compute.backend_vmss_id
  sql_database_id       = module.database.sql_database_id
  tags                  = local.tags
}

module "resilience" {
  source              = "./modules/resilience"
  name_prefix         = local.name_prefix
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  tags                = local.tags
}
