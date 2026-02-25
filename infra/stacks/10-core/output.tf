output "core_rg_name" {
  value = azurerm_resource_group.rg.name
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.law.id
}

output "app_insights_connection_string" {
  value     = azurerm_application_insights.appi.connection_string
  sensitive = true
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "subnet_private_endpoints_id" {
  value = azurerm_subnet.snet_private_endpoints.id
}

output "private_dns_zone_kv_id" {
  value = azurerm_private_dns_zone.kv.id
}

output "private_dns_zone_blob_id" {
  value = azurerm_private_dns_zone.blob.id
}