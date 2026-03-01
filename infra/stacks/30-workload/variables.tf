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

# from 10-core
variable "core_rg_name" {
  type    = string
  default = "rg-azure-zero-trust-serverless-api-dev-core"
}

variable "app_insights_connection_string" {
  type      = string
  sensitive = true
}

# from 20-private-services
variable "private_rg_name" {
  type    = string
  default = "rg-azure-zero-trust-serverless-api-dev-private"
}

variable "key_vault_id" {
  type    = string
  default = "/subscriptions/b5495b24-716e-4bec-9da9-cd8444872237/resourceGroups/rg-azure-zero-trust-serverless-api-dev-private/providers/Microsoft.KeyVault/vaults/kv-dev-4r97r7"
}

variable "key_vault_uri" {
  type    = string
  default = "https://kv-dev-4r97r7.vault.azure.net/"
}

variable "storage_account_name" {
  type    = string
  default = "stztdev4r97r7"
}