data "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  resource_group_name = var.azure_resource_group
}

locals {
  config_context_auth_info = data.azurerm_kubernetes_cluster.aks.kube_config.0.username
  config_context_cluster   = var.cluster_name
}

module "get_tls" {
  source          = "../../../../modules/tls"
  secrets_storage = var.secrets_storage
  cluster_name    = var.cluster_name
}

########################################################
# Legion setup
########################################################
# module "legion" {
#   source                   = "../../../../modules/legion"
#   cluster_name             = var.cluster_name
#   config_context_auth_info = local.config_context_auth_info
#   config_context_cluster   = local.config_context_cluster
#   tls_key                  = module.get_tls.tls_secret_key
#   tls_crt                  = module.get_tls.tls_secret_crt
#   zone                     = var.zone
#   region                   = var.region
#   project_id               = var.project_id
#   legion_helm_repo         = var.legion_helm_repo
#   root_domain              = var.root_domain
#   docker_repo              = var.docker_repo
#   docker_user              = var.docker_user
#   docker_password          = var.docker_password
#   legion_version           = var.legion_version
#   collector_region         = var.collector_region
#   legion_data_bucket       = var.legion_data_bucket
#   git_examples_key         = var.git_examples_key
#   model_docker_url         = var.model_docker_url
#   git_examples_uri         = var.git_examples_uri
#   git_examples_reference   = var.git_examples_reference
#   model_resources_cpu      = var.model_resources_cpu
#   model_resources_mem      = var.model_resources_mem
#   api_private_key          = var.api_private_key
#   api_public_key           = var.api_public_key
#   mlflow_toolchain_version = var.mlflow_toolchain_version
#   git_examples_description = var.git_examples_description
#   git_examples_web_ui_link = var.git_examples_web_ui_link
# }