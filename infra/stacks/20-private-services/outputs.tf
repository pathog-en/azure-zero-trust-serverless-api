output "private_rg_name" {
  value = azurerm_resource_group.rg.name
}

output "key_vault_id" {
  value = azurerm_key_vault.kv.id
}

output "key_vault_name" {
  value = azurerm_key_vault.kv.name
}

output "key_vault_uri" {
  value = azurerm_key_vault.kv.vault_uri
}

output "storage_account_name" {
  value = azurerm_storage_account.sa.name
}

output "storage_account_id" {
  value = azurerm_storage_account.sa.id
}

output "kv_private_endpoint_id" {
  value = azurerm_private_endpoint.kv_pe.id
}

output "blob_private_endpoint_id" {
  value = azurerm_private_endpoint.blob_pe.id
}

output "storage_account_primary_access_key" {
  value     = azurerm_storage_account.sa.primary_access_key
  sensitive = true
}

output "storage_account_primary_connection_string" {
  value     = azurerm_storage_account.sa.primary_connection_string
  sensitive = true
}