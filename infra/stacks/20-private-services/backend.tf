terraform {
  backend "azurerm" {
    resource_group_name  = "rg-azure-zero-trust-serverless-api-dev-tfstate"
    storage_account_name = "stztdev6b7c5tsk"
    container_name       = "tfstate"
    key                  = "20-private-services.tfstate"
  }
}