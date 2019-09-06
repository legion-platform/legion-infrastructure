locals {
  common_tags = merge(
    { "cluster" = var.cluster_name },
    var.aks_common_tags)
}

########################################################
# Retrieve SSH key from secrets_storage
# TODO: move to separate module
########################################################

data "aws_s3_bucket_object" "ssh_public_key" {
  bucket = var.secrets_storage
  key    = "${var.cluster_name}/ssh/${var.cluster_name}.pub"
}

data "azurerm_public_ip" "aks_ext" {
  name                = var.public_ip_name
  resource_group_name = var.azure_resource_group
}

# module "azure_monitoring" {
#   source   = "../../../../modules/azure/azure_monitoring"
#   enabled        = var.azure_monitoring_enabled
#   cluster_name   = var.cluster_name
#   tags           = local.common_tags
#   location       = module.aks_resource_group.location
#   resource_group = module.aks_resource_group.name
# }

module "aks_vpc" {
  source         = "../../../../modules/azure/networking/vpc"
  cluster_name   = var.cluster_name
  tags           = local.common_tags
  location       = var.azure_location
  resource_group = var.azure_resource_group
  subnet_cidr    = var.aks_cidr
  fw_subnet_cidr = var.fw_cidr
}

module "aks_bastion_host" {
  source           = "../../../../modules/azure/bastion"
  cluster_name     = var.cluster_name
  location         = var.azure_location
  resource_group   = var.azure_resource_group
  aks_subnet_id    = module.aks_vpc.subnet_id
  bastion_ssh_user = "ubuntu"
  bastion_tags     = local.common_tags
}

module "aks_cluster" {
  source                     = "../../../../modules/azure/aks_cluster"
  cluster_name               = var.cluster_name
  aks_tags                   = local.common_tags
  location                   = var.azure_location
  resource_group             = var.azure_resource_group
  aks_dns_prefix             = var.aks_dns_prefix
  aks_subnet_id              = module.aks_vpc.subnet_id
  sp_id                      = var.azure_client_id
  sp_secret                  = var.azure_client_secret
  k8s_version                = var.k8s_version
  ssh_user                   = "ubuntu"
  ssh_public_key             = data.aws_s3_bucket_object.ssh_public_key.body
  node_machine_type          = var.node_machine_type
  node_disk_size_gb          = var.node_disk_size_gb
  aks_num_nodes_min          = var.aks_num_nodes_min
  aks_num_nodes_max          = var.aks_num_nodes_max
  aks_analytics_enabled      = var.azure_monitoring_enabled
  #aks_analytics_workspace_id = module.azure_monitoring.workspace_id
}

# module "aks_vpc_firewall" {
#   source           = "../../../../modules/azure/networking/firewall"
#   cluster_name     = var.cluster_name
#   location         = module.aks_resource_group.location
#   resource_group   = module.aks_resource_group.name
#   allowed_ips      = var.allowed_ips
#   lb_ip_address_id = module.aks_cluster.lb_ip_address_id
#   lb_ip_address    = module.aks_cluster.lb_ip_address
#   subnet_id        = module.aks_vpc.subnet_id
#   tags             = local.common_tags
# }

module "aks_bastion_host" {
  source                 = "../../../../modules/azure/bastion"
  cluster_name           = var.cluster_name
  location               = module.aks_resource_group.location
  resource_group         = module.aks_resource_group.name
  aks_subnet_id          = module.aks_vpc.subnet_id
  bastion_ssh_user       = "ubuntu"
  bastion_ssh_public_key = data.aws_s3_bucket_object.ssh_public_key.body
  bastion_tags           = local.common_tags
}

resource "local_file" "kubeconfig" {
  sensitive_content = module.aks_cluster.kube_config
  filename          = "/root/.kube/config"
}