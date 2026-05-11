resource "azurerm_recovery_services_vault" "main" {
  name                = "rsv-${var.name_prefix}-dr"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  storage_mode_type   = "GeoRedundant"
  tags                = var.tags
}

resource "azurerm_backup_policy_vm" "daily" {
  name                = "bkpol-${var.name_prefix}-vm-daily"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.main.name
  timezone            = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 14
  }

  retention_weekly {
    count    = 4
    weekdays = ["Sunday"]
  }
}
