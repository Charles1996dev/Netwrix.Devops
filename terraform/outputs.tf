output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "web_app_name" {
  value = azurerm_linux_web_app.app.name
}

output "web_app_default_hostname" {
  value = azurerm_linux_web_app.app.default_hostname
}

output "application_gateway_public_ip" {
  value = azurerm_public_ip.agw.ip_address
}

output "postgres_server_fqdn" {
  value = azurerm_postgresql_flexible_server.db.fqdn
}

output "key_vault_name" {
  value = azurerm_key_vault.main.name
}
