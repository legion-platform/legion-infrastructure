########################################################
# Deploy AKS cluster
########################################################

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group
  # https://github.com/Azure/AKS/issues/3
  # There's additional resource group created, that used to represent and hold the lifecycle of 
  # k8s cluster resources. We only can set a name for it.
  node_resource_group = "${var.resource_group}-k8s"
  dns_prefix          = var.aks_dns_prefix
  kubernetes_version  = var.k8s_version
  
  linux_profile {
    admin_username = var.ssh_user
    ssh_key {
      key_data = var.ssh_public_key
    }
  }

  agent_pool_profile {
    name                = "basic"
    vm_size             = var.node_machine_type
    os_type             = "Linux"
    os_disk_size_gb     = var.node_disk_size_gb
    vnet_subnet_id      = var.aks_subnet_id
    count               = var.aks_num_nodes_init

    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    min_count           = var.aks_num_nodes_min
    max_count           = var.aks_num_nodes_max
    max_pods            = var.aks_num_pods
  }

  # agent_pool_profile {
  #   name                = "highcpu"
  #   vm_size             = var.node_machine_type_highcpu
  #   os_type             = "Linux"
  #   os_disk_size_gb     = var.node_disk_size_gb
  #   vnet_subnet_id      = var.aks_subnet_id

  #   type                = "VirtualMachineScaleSets"
  #   enable_auto_scaling = "true"
  #   min_count           = "1"
  #   max_count           = var.aks_highcpu_num_nodes_max

  #   node_taints = [
  #     "dedicated=jenkins-slave:NoSchedule"
  #   ]
  # }

  # We have to provide Service Principal account credentials in order to create node resource group
  # and appropriate dynamic resources, related to AKS (node resource groups, network security groups,
  # virtual machine scale sets, loadbalancers)
  service_principal {
    client_id     = var.sp_id
    client_secret = var.sp_secret
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = var.aks_analytics_workspace_id
    }
  }

  role_based_access_control {
    enabled = true
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
    #pod_cidr: ""
    #service_cidr: "10.0.0.0/16"
    #dns_service_ip: "10.0.0.10"
    #docker_bridge_cidr: "172.17.0.1/16"
    #load_balancer_sku: "basic"
  }

  tags = var.aks_tags
}
