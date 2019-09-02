########################################################
# Bastion host
########################################################

resource "azurerm_public_ip" "aks_bastion_publicip" {
  name                = "${var.cluster_name}-bastion"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  tags                = var.bastion_tags
}

# We gonna create bastion host in AKS subnet
resource "azurerm_network_interface" "aks_bastion_nic" {
  name                = "${var.bastion_hostname}-${var.cluster_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "bastion-public-ip"
    subnet_id                     = var.aks_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.aks_bastion_publicip.id
  }
}

resource "azurerm_virtual_machine" "aks_bastion" {
  name                  = "${var.bastion_hostname}-${var.cluster_name}"
  location              = var.location
  resource_group_name   = var.resource_group
  network_interface_ids = [ azurerm_network_interface.aks_bastion_nic.id ]
  vm_size               = var.bastion_machine_type

  delete_os_disk_on_termination    = true
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
    admin_username = var.bastion_ssh_user
  }
  
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.bastion_ssh_user}/.ssh/authorized_keys"
      key_data = var.bastion_ssh_public_key
    }
  }
  
  tags = var.bastion_tags
}