provider "azurerm" {
  version = "1.33.1"
}

provider "aws" {
  version = "2.28.1"
}

provider "kubernetes" {
  version                  = "1.9.0"
  config_context_auth_info = local.config_context_auth_info
  config_context_cluster   = local.config_context_cluster
}
