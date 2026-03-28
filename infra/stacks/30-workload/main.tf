locals {
  name = "${var.project}-${var.env}"
  tags = merge(var.tags, {
    project = var.project
    env     = var.env
  })
}

data "terraform_remote_state" "core" {
  backend = "azurerm"

  config = {
    resource_group_name  = "rg-azure-zero-trust-serverless-api-dev-tfstate"
    storage_account_name = "stztdev6b7c5tsk"
    container_name       = "tfstate"
    key                  = "10-core.tfstate"
  }
}

data "terraform_remote_state" "private" {
  backend = "azurerm"

  config = {
    resource_group_name  = "rg-azure-zero-trust-serverless-api-dev-tfstate"
    storage_account_name = "stztdev6b7c5tsk"
    container_name       = "tfstate"
    key                  = "20-private-services.tfstate"
  }
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

resource "azurerm_service_plan" "plan" {
  name                = "asp-${local.name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  os_type  = "Linux"
  sku_name = "B1"

  tags = local.tags
}

resource "azurerm_linux_function_app" "func" {
  name                = "func-${var.env}-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  service_plan_id = azurerm_service_plan.plan.id

  storage_account_name       = data.terraform_remote_state.private.outputs.storage_account_name
  storage_account_access_key = data.terraform_remote_state.private.outputs.storage_account_primary_access_key

  virtual_network_subnet_id = data.terraform_remote_state.core.outputs.subnet_app_integration_id

  https_only                    = true
  public_network_access_enabled = false

  # Enable this after PE validation:
  # public_network_access_enabled = false

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_insights_connection_string = data.terraform_remote_state.core.outputs.app_insights_connection_string
    ftps_state                             = "Disabled"
    minimum_tls_version                    = "1.2"
    vnet_route_all_enabled                 = true

    application_stack {
      python_version = "3.12.9"
    }
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME              = "python"
    APPLICATIONINSIGHTS_CONNECTION_STRING = data.terraform_remote_state.core.outputs.app_insights_connection_string
    KEY_VAULT_URI                         = data.terraform_remote_state.private.outputs.key_vault_uri
  }

  tags = local.tags
}

resource "azurerm_role_assignment" "kv_secrets_user" {
  scope                = data.terraform_remote_state.private.outputs.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_function_app.func.identity[0].principal_id
}

resource "azurerm_private_endpoint" "func_pe" {
  name                = "pe-func-${var.env}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = data.terraform_remote_state.core.outputs.subnet_private_endpoints_id

  private_service_connection {
    name                           = "psc-func-${var.env}"
    private_connection_resource_id = azurerm_linux_function_app.func.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "pdzg-func-${var.env}"
    private_dns_zone_ids = [data.terraform_remote_state.core.outputs.private_dns_zone_appsvc_id]
  }

  tags = local.tags
}