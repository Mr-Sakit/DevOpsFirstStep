resource "azurerm_public_ip" "appgw" {
  name                = "pip-${var.name_prefix}-appgw"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  tags                = var.tags
}

resource "azurerm_web_application_firewall_policy" "main" {
  name                = "waf-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  dynamic "custom_rules" {
    for_each = length(var.threat_intel_block_ips) > 0 ? [1] : []

    content {
      name      = "BlockThreatIntelIPs"
      priority  = 50
      rule_type = "MatchRule"
      action    = "Block"

      match_conditions {
        match_variables {
          variable_name = "RemoteAddr"
        }

        operator           = "IPMatch"
        negation_condition = false
        match_values       = var.threat_intel_block_ips
      }
    }
  }

  custom_rules {
    name                 = "RateLimitLayer7Flood"
    priority             = 60
    rule_type            = "RateLimitRule"
    action               = "Block"
    rate_limit_duration  = "OneMin"
    rate_limit_threshold = 120
    group_rate_limit_by  = "ClientAddr"

    match_conditions {
      match_variables {
        variable_name = "RequestUri"
      }

      operator           = "Regex"
      negation_condition = false
      match_values       = [".*"]
    }
  }

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    max_request_body_size_in_kb = 128
    file_upload_limit_in_mb     = 100
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }
}

resource "azurerm_application_gateway" "main" {
  name                = "agw-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  firewall_policy_id  = azurerm_web_application_firewall_policy.main.id
  tags                = var.tags

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  autoscale_configuration {
    min_capacity = 1
    max_capacity = 3
  }

  gateway_ip_configuration {
    name      = "appgw-ipconfig"
    subnet_id = var.app_gateway_subnet_id
  }

  frontend_ip_configuration {
    name                 = "public-frontend"
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_port {
    name = "https"
    port = 443
  }

  ssl_certificate {
    name     = "secureflow-local-cert"
    data     = var.ssl_certificate_base64
    password = var.ssl_certificate_password
  }

  backend_address_pool {
    name         = "frontend-pool"
    ip_addresses = [var.frontend_load_balancer_private_ip]
  }

  backend_address_pool {
    name         = "backend-pool"
    ip_addresses = [var.backend_load_balancer_private_ip]
  }

  backend_http_settings {
    name                  = "frontend-http"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
    probe_name            = "frontend-probe"
  }

  backend_http_settings {
    name                  = "backend-http"
    cookie_based_affinity = "Disabled"
    port                  = 8080
    protocol              = "Http"
    request_timeout       = 30
    probe_name            = "backend-probe"
  }

  probe {
    name                                      = "frontend-probe"
    protocol                                  = "Http"
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 10
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = false
    host                                      = "127.0.0.1"
  }

  probe {
    name                                      = "backend-probe"
    protocol                                  = "Http"
    path                                      = "/api/health"
    interval                                  = 30
    timeout                                   = 10
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = false
    host                                      = "127.0.0.1"
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "public-frontend"
    frontend_port_name             = "http"
    protocol                       = "Http"
    host_name                      = "e-document.tech"
  }

  http_listener {
    name                           = "https-listener"
    frontend_ip_configuration_name = "public-frontend"
    frontend_port_name             = "https"
    protocol                       = "Https"
    ssl_certificate_name           = "secureflow-local-cert"
  }

  redirect_configuration {
    name                 = "http-to-https"
    redirect_type        = "Permanent"
    target_listener_name = "https-listener"
    include_path         = true
    include_query_string = true
  }

  request_routing_rule {
    name                        = "http-redirect"
    rule_type                   = "Basic"
    http_listener_name          = "http-listener"
    redirect_configuration_name = "http-to-https"
    priority                    = 90
  }

  url_path_map {
    name                               = "secureflow-routes"
    default_backend_address_pool_name  = "frontend-pool"
    default_backend_http_settings_name = "frontend-http"

    path_rule {
      name                       = "api"
      paths                      = ["/api/*"]
      backend_address_pool_name  = "backend-pool"
      backend_http_settings_name = "backend-http"
    }
  }

  request_routing_rule {
    name               = "https-path-routing"
    rule_type          = "PathBasedRouting"
    http_listener_name = "https-listener"
    url_path_map_name  = "secureflow-routes"
    priority           = 100
  }
}
