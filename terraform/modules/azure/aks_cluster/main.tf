########################################################
# Retrieve SSH key from secrets_storage
# TODO: move to separate module
########################################################

data "aws_s3_bucket_object" "ssh_public_key" {
  bucket = var.secrets_storage
  key    = "${var.cluster_name}/ssh/${var.cluster_name}.pub"
}

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
      key_data = data.aws_s3_bucket_object.ssh_public_key.body
    }
  }

  agent_pool_profile {
    name                = "basic"
    vm_size             = var.node_machine_type
    os_type             = "Linux"
    os_disk_size_gb     = var.node_disk_size_gb
    vnet_subnet_id      = var.aks_subnet_id
    count               = var.aks_num_nodes_min

    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = "true"
    min_count           = var.aks_num_nodes_min
    max_count           = var.aks_num_nodes_max
    #availability_zones  = ["1", "2"]
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

  service_principal {
    client_id     = var.sp_id
    client_secret = var.sp_secret
  }

  addon_profile {
    # TODO: add condition
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
  }

  tags = var.aks_tags
}

########################################################
# Assign public IP to AKS node resource group
########################################################

resource "azurerm_public_ip" "ext_ip" {
  name                = "${var.cluster_name}-extip"
  location            = var.location
  resource_group_name = azurerm_kubernetes_cluster.aks.node_resource_group
  allocation_method   = "Static"
  tags                = var.aks_tags
}

########################################################
# Bastion host
# TODO: move to separate module
########################################################

resource "azurerm_network_interface" "aks_bastion_nic" {
  name                = "${var.bastion_hostname}-${var.cluster_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "bastionip"
    subnet_id                     = var.aks_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.aks_bastion_publicip.id
  }
}

resource "azurerm_public_ip" "aks_bastion_publicip" {
  name                = "${var.cluster_name}-bastion"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  tags                = var.bastion_tags
}

resource "azurerm_virtual_machine" "aks_bastion" {
  name                  = "${var.bastion_hostname}-${var.cluster_name}"
  location              = var.location
  resource_group_name   = var.resource_group
  network_interface_ids = [ azurerm_network_interface.aks_bastion_nic.id ]
  vm_size               = var.bastion_machine_type

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.bastion_hostname}-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.bastion_hostname}-${var.cluster_name}"
    admin_username = var.ssh_user
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.ssh_user}/.ssh/authorized_keys"
      key_data = data.aws_s3_bucket_object.ssh_public_key.body
    }
  }
  tags = var.bastion_tags

  depends_on = [azurerm_kubernetes_cluster.aks]
}