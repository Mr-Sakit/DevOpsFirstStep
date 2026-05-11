output "application_gateway_public_ip" {
  description = "Only public endpoint for SecureFlow Docs."
  value       = module.app_gateway.public_ip_address
}

output "application_gateway_https_url" {
  value = "https://${module.app_gateway.public_ip_address}/"
}

output "frontend_vmss_name" {
  value = module.compute.frontend_vmss_name
}

output "backend_vmss_name" {
  value = module.compute.backend_vmss_name
}

output "frontend_internal_load_balancer_name" {
  value = module.load_balancer.frontend_lb_name
}

output "backend_internal_load_balancer_name" {
  value = module.load_balancer.backend_lb_name
}

output "frontend_internal_load_balancer_private_ip" {
  value = module.load_balancer.frontend_lb_private_ip
}

output "backend_internal_load_balancer_private_ip" {
  value = module.load_balancer.backend_lb_private_ip
}

output "bastion_host_name" {
  value = module.bastion.bastion_host_name
}

output "sql_private_endpoint_fqdn" {
  value = module.database.sql_private_fqdn
}

output "monthly_budget_name" {
  value = module.monitoring.monthly_budget_name
}

output "cost_anomaly_alert_name" {
  value = module.monitoring.cost_anomaly_alert_name
}

output "cost_management_view_name" {
  value = module.monitoring.cost_management_view_name
}

output "cis_policy_assignment_name" {
  value = module.monitoring.cis_policy_assignment_name
}

output "cis_policy_initiative_name" {
  value = module.monitoring.cis_policy_initiative_name
}

output "compliance_mode_score" {
  value = module.monitoring.compliance_mode_score
}

output "recovery_services_vault_name" {
  value = module.resilience.recovery_services_vault_name
}

output "vm_backup_policy_name" {
  value = module.resilience.vm_backup_policy_name
}

output "sql_pitr_retention_days" {
  value = module.resilience.sql_pitr_retention_days
}

output "dr_readiness_score" {
  value = module.resilience.dr_readiness_score
}

output "ai_api_traffic_spike_alert_name" {
  value = module.monitoring.ai_api_traffic_spike_alert_name
}

output "ai_failed_login_burst_alert_name" {
  value = module.monitoring.ai_failed_login_burst_alert_name
}

output "ai_security_summary_score" {
  value = module.monitoring.ai_security_summary_score
}

output "key_vault_name" {
  value = module.key_vault.key_vault_name
}

output "key_vault_uri" {
  value = module.key_vault.key_vault_uri
}

output "key_vault_private_endpoint_name" {
  value = module.key_vault.key_vault_private_endpoint_name
}

output "threat_intel_waf_rule_name" {
  value = "BlockThreatIntelIPs"
}

output "threat_intel_blocked_ip_count" {
  value = length(var.threat_intel_block_ips)
}
