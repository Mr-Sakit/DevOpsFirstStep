output "app_gateway_id" { value = azurerm_application_gateway.main.id }
output "public_ip_address" { value = azurerm_public_ip.appgw.ip_address }
output "frontend_backend_pool_id" {
  value = one([
    for pool in azurerm_application_gateway.main.backend_address_pool : pool.id
    if pool.name == "frontend-pool"
  ])
}
output "api_backend_pool_id" {
  value = one([
    for pool in azurerm_application_gateway.main.backend_address_pool : pool.id
    if pool.name == "backend-pool"
  ])
}
