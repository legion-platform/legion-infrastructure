data "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  resource_group_name = "${var.cluster_name}-rg"
}

locals {
  config_context_auth_info = data.azurerm_kubernetes_cluster.aks.kube_config.0.username
  config_context_cluster   = var.cluster_name
}

########################################################
# Helm initialization
########################################################
module "helm_init" {
  source = "../../../../modules/helm_init"
}
