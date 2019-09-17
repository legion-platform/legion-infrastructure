provider "azurerm" {
  version         = "= 1.33.1"
}

provider "helm" {
  version         = "=0.10.2"
  namespace       = "kube-system"
  service_account = "tiller"
}

provider "aws" {
  version                 = "~> 2.25"
  region                  = var.aws_region
  shared_credentials_file = var.aws_credentials_file
  profile                 = var.aws_profile
}

provider "kubernetes" {
  version                  = "~> 1.9"
  config_context_auth_info = local.config_context_auth_info
  config_context_cluster   = local.config_context_cluster
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}