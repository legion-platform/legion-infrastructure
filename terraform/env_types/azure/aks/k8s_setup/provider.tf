provider "azurerm" {
  version         = "~> 1.32"
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
}

provider "helm" {
  version         = "=0.10.2"
  #install_tiller  = true
  namespace       = "kube-system"
  service_account = "tiller"
  #tiller_image    = var.tiller_image
  #init_helm_home  = true

  # kubernetes {
  #   config_context = local.config_context_auth_info
  # }
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