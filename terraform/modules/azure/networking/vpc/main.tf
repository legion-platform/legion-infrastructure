########################################################
# Create virtual network
########################################################

resource "azurerm_virtual_network" "vpc" {
  name                = "${var.cluster_name}-vpc"
  # We'll add AKS subnet and firewall subnet accordingly to VPC address space
  address_space       = [ var.subnet_cidr, var.fw_subnet_cidr ]
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags
}

########################################################
# Create subnet for AKS nodes in VPC
########################################################

resource "azurerm_subnet" "subnet" {
  name                 = "${var.cluster_name}-subnet"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.vpc.name
  address_prefix       = var.subnet_cidr
  lifecycle {
    ignore_changes = [
      # Ignore changes to route_table_id, as it is changed later in firewall module
      # (module.aks_firewall.azurerm_subnet_route_table_association.vpc_routing)
      route_table_id,
    ]
  }
}