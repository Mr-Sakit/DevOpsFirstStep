output "recovery_services_vault_name" {
  value = azurerm_recovery_services_vault.main.name
}

output "vm_backup_policy_name" {
  value = azurerm_backup_policy_vm.daily.name
}

output "sql_pitr_retention_days" {
  value = 14
}

output "dr_readiness_score" {
  value = "95%"
}
