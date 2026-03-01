variable "env" {
  type    = string
  default = "dev"
}

variable "location" {
  type    = string
  default = "centralus"
}

variable "project" {
  type    = string
  default = "azure-zero-trust-serverless-api"
}

variable "tags" {
  type = map(string)
  default = {
    owner = "pat"
    repo  = "azure-zero-trust-serverless-api"
  }
}

# from 10-core outputs
variable "core_rg_name" {
  type    = string
  default = "rg-azure-zero-trust-serverless-api-dev-core"
}

variable "subnet_private_endpoints_id" {
  type    = string
  default = "/subscriptions/b5495b24-716e-4bec-9da9-cd8444872237/resourceGroups/rg-azure-zero-trust-serverless-api-dev-core/providers/Microsoft.Network/virtualNetworks/vnet-azure-zero-trust-serverless-api-dev/subnets/snet-private-endpoints"
}

variable "private_dns_zone_kv_id" {
  type    = string
  default = "/subscriptions/b5495b24-716e-4bec-9da9-cd8444872237/resourceGroups/rg-azure-zero-trust-serverless-api-dev-core/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"
}

variable "private_dns_zone_blob_id" {
  type    = string
  default = "/subscriptions/b5495b24-716e-4bec-9da9-cd8444872237/resourceGroups/rg-azure-zero-trust-serverless-api-dev-core/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
}

variable "log_analytics_workspace_id" {
  type    = string
  default = "/subscriptions/b5495b24-716e-4bec-9da9-cd8444872237/resourceGroups/rg-azure-zero-trust-serverless-api-dev-core/providers/Microsoft.OperationalInsights/workspaces/law-azure-zero-trust-serverless-api-dev"
}

variable "disable_storage_shared_key" {
  type    = bool
  default = true
}