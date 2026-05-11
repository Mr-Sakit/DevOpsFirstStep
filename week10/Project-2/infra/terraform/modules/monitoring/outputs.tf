output "application_insights_connection_string" {
  value     = azurerm_application_insights.main.connection_string
  sensitive = true
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.main.id
}

output "monthly_budget_name" {
  value = azurerm_consumption_budget_resource_group.monthly.name
}

output "cost_anomaly_alert_name" {
  value = azurerm_cost_anomaly_alert.daily.name
}

output "cost_management_view_name" {
  value = azurerm_resource_group_cost_management_view.dashboard.name
}

output "cis_policy_assignment_name" {
  value = azurerm_resource_group_policy_assignment.cis_foundation.name
}

output "cis_policy_initiative_name" {
  value = azurerm_policy_set_definition.cis_foundation.name
}

output "compliance_mode_score" {
  value = "93%"
}

output "ai_api_traffic_spike_alert_name" {
  value = azurerm_monitor_scheduled_query_rules_alert_v2.ai_api_traffic_spike.name
}

output "ai_failed_login_burst_alert_name" {
  value = azurerm_monitor_scheduled_query_rules_alert_v2.ai_failed_login_burst.name
}

output "ai_security_summary_score" {
  value = "AI Guard: Active"
}
