locals {
  project  = "azure-zero-trust-serverless-api"
  env      = var.env
  location = var.location
  name     = "${local.project}-${local.env}"

  tags = merge(var.tags, {
    project = local.project
    env     = local.env
  })
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.name}-core"
  location = local.location
  tags     = local.tags
}

# -------- Monitoring --------
resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-${local.name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = local.tags
}

resource "azurerm_application_insights" "appi" {
  name                = "appi-${local.name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.law.id
  tags                = local.tags
}

# -------- Network --------
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${local.name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet_cidr]
  tags                = local.tags
}

resource "azurerm_subnet" "snet_private_endpoints" {
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.snet_private_endpoints_cidr]

  private_endpoint_network_policies = "Enabled"
}

# -------- Private DNS Zones --------
resource "azurerm_private_dns_zone" "kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv_link" {
  name                  = "kv-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.kv.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
  tags                  = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob_link" {
  name                  = "blob-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
  tags                  = local.tags
}