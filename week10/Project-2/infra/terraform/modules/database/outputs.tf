output "sql_server_name" { value = azurerm_mssql_server.main.name }
output "sql_database_id" { value = azurerm_mssql_database.main.id }
output "sql_private_fqdn" { value = "${azurerm_mssql_server.main.name}.privatelink.database.windows.net" }
