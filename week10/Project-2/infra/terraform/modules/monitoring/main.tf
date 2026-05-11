resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_application_insights" "main" {
  name                = "appi-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.main.id
  tags                = var.tags
}

data "azurerm_client_config" "current" {}

resource "azurerm_policy_definition" "audit_sql_public_network_disabled" {
  name         = "policy-${var.name_prefix}-sql-private-access"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "SecureFlow CIS - SQL public network access disabled"
  description  = "Audits Azure SQL servers where public network access is not disabled."

  metadata = jsonencode({
    category = "CIS Microsoft Azure Foundations Benchmark"
    control  = "Secure database networking"
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Sql/servers"
        },
        {
          field     = "Microsoft.Sql/servers/publicNetworkAccess"
          notEquals = "Disabled"
        }
      ]
    }
    then = {
      effect = "audit"
    }
  })
}

resource "azurerm_policy_definition" "audit_public_nics" {
  name         = "policy-${var.name_prefix}-no-public-nics"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "SecureFlow CIS - compute has no public NIC exposure"
  description  = "Audits network interfaces that reference a public IP configuration."

  metadata = jsonencode({
    category = "CIS Microsoft Azure Foundations Benchmark"
    control  = "Restrict public management exposure"
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Network/networkInterfaces"
        },
        {
          count = {
            field = "Microsoft.Network/networkInterfaces/ipconfigurations[*]"
            where = {
              field  = "Microsoft.Network/networkInterfaces/ipconfigurations[*].publicIpAddress.id"
              exists = true
            }
          }
          greater = 0
        }
      ]
    }
    then = {
      effect = "audit"
    }
  })
}

resource "azurerm_policy_definition" "audit_app_gateway_waf" {
  name         = "policy-${var.name_prefix}-appgw-waf-v2"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "SecureFlow CIS - Application Gateway WAF v2 enabled"
  description  = "Audits Application Gateway resources that are not deployed with WAF v2 tier."

  metadata = jsonencode({
    category = "CIS Microsoft Azure Foundations Benchmark"
    control  = "Protect public ingress with WAF"
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Network/applicationGateways"
        },
        {
          field     = "Microsoft.Network/applicationGateways/sku.tier"
          notEquals = "WAF_v2"
        }
      ]
    }
    then = {
      effect = "audit"
    }
  })
}

resource "azurerm_policy_set_definition" "cis_foundation" {
  name         = "initiative-${var.name_prefix}-cis-foundation"
  policy_type  = "Custom"
  display_name = "SecureFlow CIS Foundation Controls"
  description  = "CIS-style Azure baseline for private ingress, private compute, and private data access."

  metadata = jsonencode({
    category = "CIS Microsoft Azure Foundations Benchmark"
  })

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.audit_sql_public_network_disabled.id
    reference_id         = "sql-public-network-disabled"
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.audit_public_nics.id
    reference_id         = "compute-no-public-nics"
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.audit_app_gateway_waf.id
    reference_id         = "app-gateway-waf-v2"
  }
}

resource "azurerm_resource_group_policy_assignment" "cis_foundation" {
  name                 = "pa-${var.name_prefix}-cis"
  resource_group_id    = var.resource_group_id
  policy_definition_id = azurerm_policy_set_definition.cis_foundation.id
  display_name         = "SecureFlow CIS Foundation Controls"
  description          = "Audits SecureFlow Docs against CIS-style controls for private networking, Azure SQL exposure, and WAF ingress."
  enforce              = false
  location             = var.location

  non_compliance_message {
    content = "SecureFlow Docs must keep compute private, SQL public access disabled, and the only public entry protected by Application Gateway WAF v2."
  }
}

resource "azurerm_monitor_action_group" "platform" {
  name                = "ag-${var.name_prefix}-platform"
  resource_group_name = var.resource_group_name
  short_name          = "sfdocs"
  tags                = var.tags

  email_receiver {
    name          = "platform-email"
    email_address = var.action_email
  }
}

resource "azurerm_consumption_budget_resource_group" "monthly" {
  name              = "budget-${var.name_prefix}-monthly"
  resource_group_id = var.resource_group_id
  amount            = var.monthly_budget_amount
  time_grain        = "Monthly"

  time_period {
    start_date = var.budget_start_date
  }

  notification {
    enabled        = true
    operator       = "GreaterThan"
    threshold      = 50
    threshold_type = "Actual"
    contact_emails = [var.action_email]
    contact_groups = [azurerm_monitor_action_group.platform.id]
  }

  notification {
    enabled        = true
    operator       = "GreaterThan"
    threshold      = 80
    threshold_type = "Actual"
    contact_emails = [var.action_email]
    contact_groups = [azurerm_monitor_action_group.platform.id]
  }

  notification {
    enabled        = true
    operator       = "GreaterThan"
    threshold      = 100
    threshold_type = "Forecasted"
    contact_emails = [var.action_email]
    contact_groups = [azurerm_monitor_action_group.platform.id]
  }
}

resource "azurerm_cost_anomaly_alert" "daily" {
  name               = "cost-anomaly-sf-dev"
  display_name       = "SecureFlow cost anomaly"
  subscription_id    = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  email_subject      = "SecureFlow Docs cost anomaly detected"
  email_addresses    = [var.action_email]
  notification_email = var.action_email
  message            = "Investigate unexpected Azure spend changes for SecureFlow Docs resources."
}

resource "azurerm_resource_group_cost_management_view" "dashboard" {
  name              = "cost-view-${var.name_prefix}-daily"
  display_name      = "SecureFlow Docs daily resource cost"
  resource_group_id = var.resource_group_id
  chart_type        = "StackedColumn"
  accumulated       = true
  timeframe         = "MonthToDate"
  report_type       = "Usage"

  dataset {
    granularity = "Daily"

    aggregation {
      name        = "totalCost"
      column_name = "Cost"
    }

    grouping {
      type = "Dimension"
      name = "ResourceType"
    }

    sorting {
      name      = "UsageDate"
      direction = "Ascending"
    }
  }

  kpi {
    type = "Forecast"
  }

  pivot {
    type = "Dimension"
    name = "ResourceType"
  }

  pivot {
    type = "Dimension"
    name = "ServiceName"
  }

  pivot {
    type = "Dimension"
    name = "ResourceId"
  }
}

resource "azurerm_monitor_metric_alert" "app_gateway_unhealthy" {
  name                = "alert-${var.name_prefix}-appgw-unhealthy"
  resource_group_name = var.resource_group_name
  scopes              = [var.app_gateway_id]
  description         = "Application Gateway backend health below 100 percent for 5 minutes."
  frequency           = "PT1M"
  window_size         = "PT5M"
  severity            = 1
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Network/applicationGateways"
    metric_name      = "HealthyHostCount"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 2
  }

  action {
    action_group_id = azurerm_monitor_action_group.platform.id
  }

  lifecycle {
    ignore_changes = [action]
  }
}

resource "azurerm_monitor_metric_alert" "frontend_cpu" {
  name                = "alert-${var.name_prefix}-frontend-cpu"
  resource_group_name = var.resource_group_name
  scopes              = [var.frontend_vm_id]
  description         = "Frontend VMSS CPU above 70 percent for 5 minutes."
  frequency           = "PT1M"
  window_size         = "PT5M"
  severity            = 2
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachineScaleSets"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 70
  }

  action {
    action_group_id = azurerm_monitor_action_group.platform.id
  }

  lifecycle {
    ignore_changes = [action]
  }
}

resource "azurerm_monitor_metric_alert" "backend_cpu" {
  name                = "alert-${var.name_prefix}-backend-cpu"
  resource_group_name = var.resource_group_name
  scopes              = [var.backend_vm_id]
  description         = "Backend VMSS CPU above 70 percent for 5 minutes."
  frequency           = "PT1M"
  window_size         = "PT5M"
  severity            = 2
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachineScaleSets"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 70
  }

  action {
    action_group_id = azurerm_monitor_action_group.platform.id
  }

  lifecycle {
    ignore_changes = [action]
  }
}

resource "azurerm_monitor_metric_alert" "sql_dtu" {
  name                = "alert-${var.name_prefix}-sql-dtu"
  resource_group_name = var.resource_group_name
  scopes              = [var.sql_database_id]
  description         = "Azure SQL DTU consumption above 80 percent for 5 minutes."
  frequency           = "PT1M"
  window_size         = "PT5M"
  severity            = 2
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "dtu_consumption_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.platform.id
  }

  lifecycle {
    ignore_changes = [action]
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "ai_api_traffic_spike" {
  name                 = "alert-${var.name_prefix}-ai-api-traffic-spike"
  resource_group_name  = var.resource_group_name
  location             = var.location
  scopes               = [azurerm_log_analytics_workspace.main.id]
  description          = "AI-assisted detector for abnormal API traffic patterns through Application Gateway."
  enabled              = true
  severity             = 2
  evaluation_frequency = "PT5M"
  window_duration      = "PT10M"
  tags                 = var.tags

  criteria {
    query                   = <<-KQL
      AzureDiagnostics
      | where TimeGenerated > ago(10m)
      | where Category in ("ApplicationGatewayAccessLog", "ApplicationGatewayFirewallLog")
      | extend RequestUri = tostring(column_ifexists("requestUri_s", ""))
      | extend ClientIP = tostring(column_ifexists("clientIP_s", "unknown"))
      | where RequestUri startswith "/api"
      | summarize RequestCount = count() by bin(TimeGenerated, 5m), ClientIP, RequestUri
      | where RequestCount > 100
    KQL
    time_aggregation_method = "Count"
    operator                = "GreaterThan"
    threshold               = 0

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.platform.id]
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "ai_failed_login_burst" {
  name                 = "alert-${var.name_prefix}-ai-failed-login-burst"
  resource_group_name  = var.resource_group_name
  location             = var.location
  scopes               = [azurerm_log_analytics_workspace.main.id]
  description          = "AI-assisted detector for repeated failed authentication attempts against SecureFlow API."
  enabled              = true
  severity             = 2
  evaluation_frequency = "PT5M"
  window_duration      = "PT10M"
  tags                 = var.tags

  criteria {
    query                   = <<-KQL
      let FailedLoginRequests = union isfuzzy=true
        (requests
          | project TimeGenerated = timestamp, Url = tostring(url), ResultCode = tostring(resultCode), ClientIP = tostring(client_IP)),
        (AppRequests
          | project TimeGenerated, Url = tostring(Url), ResultCode = tostring(ResultCode), ClientIP = tostring(ClientIP));
      FailedLoginRequests
      | where TimeGenerated > ago(10m)
      | where Url has "/api/auth/login"
      | where ResultCode in ("401", "403")
      | summarize FailedAttempts = count() by bin(TimeGenerated, 5m), ClientIP
      | where FailedAttempts > 5
    KQL
    time_aggregation_method = "Count"
    operator                = "GreaterThan"
    threshold               = 0

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.platform.id]
  }
}

resource "azurerm_monitor_diagnostic_setting" "app_gateway" {
  name                       = "diag-${var.name_prefix}-appgw"
  target_resource_id         = var.app_gateway_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "ApplicationGatewayAccessLog"
  }

  enabled_log {
    category = "ApplicationGatewayFirewallLog"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
