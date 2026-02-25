variable "env" {
  type    = string
  default = "dev"
}

variable "location" {
  type    = string
  default = "eastus2"
}

variable "tags" {
  type = map(string)
  default = {
    owner = "pat"
    repo  = "azure-zero-trust-serverless-api"
  }
}

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "vnet_cidr" {
  type    = string
  default = "10.60.0.0/16"
}

variable "snet_private_endpoints_cidr" {
  type    = string
  default = "10.60.10.0/24"
}