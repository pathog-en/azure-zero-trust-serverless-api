locals {
  name = "${var.project}-${var.env}"
  tags = merge(var.tags, { project = var.project, env = var.env })
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.name}-workload"
  location = var.location
  tags     = local.tags
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

# Consumption plan (lowest cost)
resource "azurerm_service_plan" "plan" {
  name                = "asp-${local.name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "Y1"
  tags                = local.tags
}

resource "azurerm_linux_function_app" "func" {
  name                = "func-${var.env}-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  service_plan_id            = azurerm_service_plan.plan.id
  storage_account_name       = var.storage_account_name
  storage_account_access_key = null # we will set via app setting later if required

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_insights_connection_string = var.app_insights_connection_string
    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "python"
    "KEY_VAULT_URI"            = var.key_vault_uri
  }

  tags = local.tags
}

# Grant Function MI permissions to read secrets (RBAC model)
resource "azurerm_role_assignment" "kv_secrets_user" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_function_app.func.identity[0].principal_id
}