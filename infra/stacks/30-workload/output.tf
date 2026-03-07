output "workload_rg_name" {
  value = azurerm_resource_group.rg.name
}

output "function_app_name" {
  value = azurerm_linux_function_app.func.name
}

output "function_app_principal_id" {
  value = azurerm_linux_function_app.func.identity[0].principal_id
}

output "function_app_default_hostname" {
  value = azurerm_linux_function_app.func.default_hostname
}

output "function_private_endpoint_id" {
  value = azurerm_private_endpoint.func_pe.id
}

output "function_private_endpoint_name" {
  value = azurerm_private_endpoint.func_pe.name
}