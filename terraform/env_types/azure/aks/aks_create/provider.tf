provider "azurerm" {
  version         = "~> 1.32"
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
}

provider "aws" {
  version                 = "~> 2.25"
  region                  = var.aws_region
  shared_credentials_file = var.aws_credentials_file
  profile                 = var.aws_profile
}

provider "random" {
  version = "~> 2.2"
}

provider "local" {
  version = "~> 1.3"
}

provider "null" {
  version = "~> 2.1"
}

provider "http" {
  version = "~> 1.1"
}

provider "tls" {
  version = "~> 2.1"
}