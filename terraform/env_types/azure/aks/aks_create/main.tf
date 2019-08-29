locals {
  common_tags = merge(
    { "cluster" = var.cluster_name },
    var.aks_common_tags)
}

module "aks_resource_group" {
  source   = "../../../../modules/azure/resource_group"
  name     = "${var.cluster_name}-rg"
  tags     = local.common_tags
  location = var.azure_location
}

module "azure_monitoring" {
  source   = "../../../../modules/azure/azure_monitoring"
  cluster_name   = var.cluster_name
  tags           = local.common_tags
  location       = module.aks_resource_group.location
  resource_group = module.aks_resource_group.name
}

module "aks_vpc" {
  source         = "../../../../modules/azure/networking/vpc"
  cluster_name   = var.cluster_name
  tags           = local.common_tags
  location       = module.aks_resource_group.location
  resource_group = module.aks_resource_group.name
  subnet_cidr    = var.aks_cidr
}

# module "aks_vpc_firewall" {
#   source                      = "../../../../modules/azure/networking/firewall"
#   cluster_name                = var.cluster_name
#   allowed_ips                 = var.allowed_ips
#   network_name                = module.aks_vpc.subnet_name
#   tags                        = local.common_tags
# }

module "aks_cluster" {
  source                     = "../../../../modules/azure/aks_cluster"
  cluster_name               = var.cluster_name
  secrets_storage            = var.secrets_storage
  aks_tags                   = local.common_tags
  location                   = module.aks_resource_group.location
  resource_group             = module.aks_resource_group.name
  aks_dns_prefix             = var.aks_dns_prefix
  aks_subnet_id              = module.aks_vpc.subnet_id
  sp_id                      = var.azure_client_id
  sp_secret                  = var.azure_client_secret
  k8s_version                = var.k8s_version
  node_machine_type          = var.node_machine_type
  node_disk_size_gb          = var.node_disk_size_gb
  aks_num_nodes_min          = var.aks_num_nodes_min
  aks_num_nodes_max          = var.aks_num_nodes_max
  aks_analytics_workspace_id = module.azure_monitoring.workspace_id
}

resource "local_file" "kubeconfig" {
  sensitive_content = module.aks_cluster.kube_config
  filename          = "/root/.kube/config"
}