locals {
  name = "${var.project}-${var.env}"
  tags = merge(var.tags, { project = var.project, env = var.env })
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.name}-private"
  location = var.location
  tags     = local.tags
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

# ---------------- Key Vault ----------------
resource "azurerm_key_vault" "kv" {
  name                = "kv-${var.env}-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tenant_id = "791dd4be-8cb6-4316-8e8e-411b90323485"
  sku_name  = "standard"

  # hardening
  purge_protection_enabled   = true
  soft_delete_retention_days = 7

  # network: private only
  public_network_access_enabled = false

  # use RBAC model (preferred)
  rbac_authorization_enabled = true

  tags = local.tags
}

resource "azurerm_monitor_diagnostic_setting" "kv_diag" {
  name                       = "diag-kv"
  target_resource_id         = azurerm_key_vault.kv.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
  }
}

# ---------------- Storage (Blob) ----------------
resource "azurerm_storage_account" "sa" {
  name                = "stzt${var.env}${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = false

  # strong Zero Trust signal (optional but good)
  shared_access_key_enabled = true

  tags = local.tags
}

resource "azurerm_monitor_diagnostic_setting" "sa_diag" {
  name                       = "diag-storage"
  target_resource_id         = azurerm_storage_account.sa.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_metric {
    category = "AllMetrics"
  }
}

# ---------------- Private Endpoints ----------------
resource "azurerm_private_endpoint" "kv_pe" {
  name                = "pe-kv-${var.env}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = var.subnet_private_endpoints_id
  tags                = local.tags

  private_service_connection {
    name                           = "psc-kv-${var.env}"
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = "zg-kv"
    private_dns_zone_ids = [var.private_dns_zone_kv_id]
  }
}

resource "azurerm_private_endpoint" "blob_pe" {
  name                = "pe-blob-${var.env}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = var.subnet_private_endpoints_id
  tags                = local.tags

  private_service_connection {
    name                           = "psc-blob-${var.env}"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "zg-blob"
    private_dns_zone_ids = [var.private_dns_zone_blob_id]
  }
}