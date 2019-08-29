########################################################
# Create virtual network
########################################################

resource "azurerm_virtual_network" "vpc" {
  name                = "${var.cluster_name}-vpc"
  # Here we assume that variable subnet_cidr is always /24
  # So for vpc address space we are just expanding it to /16
  address_space       = [ cidrsubnet(var.subnet_cidr, -8, 0) ]
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags
}

########################################################
# Create subnet in VPC
########################################################

resource "azurerm_subnet" "subnet" {
  name                 = "${var.cluster_name}-subnet"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.vpc.name
  address_prefix       = var.subnet_cidr
}
