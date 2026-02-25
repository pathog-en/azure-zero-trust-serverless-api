terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.61"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "b5495b24-716e-4bec-9da9-cd8444872237"
  tenant_id       = "791dd4be-8cb6-4316-8e8e-411b90323485"
}