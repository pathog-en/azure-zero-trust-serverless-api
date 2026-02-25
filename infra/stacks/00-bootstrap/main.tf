locals {
  project  = "azure-zero-trust-serverless-api"
  env      = "dev"
  location = "eastus2"
  name     = "${local.project}-${local.env}"
  tags = {
    project = local.project
    env     = local.env
    repo    = local.project
  }
}

resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.name}-tfstate"
  location = local.location
  tags     = local.tags
}

resource "azurerm_storage_account" "sa" {
  name                     = "stzt${local.env}${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2"

  tags = local.tags
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

output "tfstate_rg" { value = azurerm_resource_group.rg.name }
output "tfstate_sa" { value = azurerm_storage_account.sa.name }
output "tfstate_container" { value = azurerm_storage_container.tfstate.name }