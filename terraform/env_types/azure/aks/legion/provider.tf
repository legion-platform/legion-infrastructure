provider "azurerm" {
  version = "1.33.1"
}

provider "aws" {
  version = "2.28.1"
}

provider "google" {
  version = "2.15.0"
}

provider "helm" {
  version         = "v0.10.0"
  namespace       = "kube-system"
  service_account = "tiller"
  install_tiller  = false
  tiller_image    = var.tiller_image
}

provider "kubernetes" {
  version                  = "1.9.0"
  config_context_auth_info = local.config_context_auth_info
  config_context_cluster   = local.config_context_cluster
}
