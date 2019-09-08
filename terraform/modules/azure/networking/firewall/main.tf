data "http" "external_ip" {
  url = "http://ifconfig.co"
}

locals {
  allowed_subnets = concat(list("${chomp(data.http.external_ip.body)}/32"), var.allowed_ips)
}

data "azurerm_public_ip" "lb" {
  name                = var.public_ip_name
  resource_group_name = var.resource_group
}

resource "azurerm_subnet" "fw_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group
  virtual_network_name = var.vpc_name
  address_prefix       = var.fw_subnet_cidr
}

resource "azurerm_firewall" "aks" {
  name                = "${var.cluster_name}-fw"
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags

  ip_configuration {
    name                 = "${var.cluster_name}-fw-ipconfig"
    subnet_id            = azurerm_subnet.fw_subnet.id
    # Data source azurerm_public_ip does not provide id for specific public IP
    # So we have to generate it from subnet id, assuming that subnet and public IP are in one resource group
    # and public IP is already created in advance
    # /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-resource-group/providers/Microsoft.Network/publicIPAddresses/my-extip
    public_ip_address_id = replace(azurerm_subnet.fw_subnet.id, "/virtualNetworks.+/", "publicIPAddresses/${var.public_ip_name}")
  }
}

resource "azurerm_firewall_nat_rule_collection" "ingress" {
  name                = "aks-dnat"
  azure_firewall_name = azurerm_firewall.aks.name
  resource_group_name = var.resource_group
  priority            = 101
  action              = "Dnat"

  rule {
    name = "ingress-http"
    source_addresses = local.allowed_subnets
    destination_ports = [ "80" ]
    destination_addresses = [ data.azurerm_public_ip.lb.ip_address ]
    protocols = [ "TCP" ]
    translated_address = var.ingress_ip
    translated_port = "80"
  }
  rule {
    name = "ingress-https"
    source_addresses = local.allowed_subnets
    destination_ports = [ "443" ]
    destination_addresses = [ data.azurerm_public_ip.lb.ip_address ]
    protocols = [ "TCP" ]
    translated_address = var.ingress_ip
    translated_port = "443"
  }
  rule {
    name = "bastion-ssh"
    source_addresses = local.allowed_subnets
    destination_ports = [ "22" ]
    destination_addresses = [ data.azurerm_public_ip.lb.ip_address ]
    protocols = [ "TCP" ]
    translated_address = var.bastion_ip
    translated_port = "22"
  }
}

resource "azurerm_firewall_network_rule_collection" "egress" {
  name                = "aks-vpc-egress"
  azure_firewall_name = azurerm_firewall.aks.name
  resource_group_name = var.resource_group
  priority            = 101
  action              = "Allow"

  rule {
    name = "allow-any-egress"
    source_addresses = [ var.aks_subnet_cidr ]
    destination_ports = [ "*" ]
    destination_addresses = [ "*" ]
    protocols = [ "Any" ]
  }
}

# Setup of default route via private firewall IP to NAT egress traffic from Public IP
data "azurerm_subnet" "aks_subnet" {
  name                 = var.aks_subnet_name
  virtual_network_name = var.vpc_name
  resource_group_name  = var.resource_group
}

resource "azurerm_route_table" "aks_routing" {
  name                = "${var.cluster_name}-routing"
  location            = var.location
  resource_group_name = var.resource_group

  route {
    name                   = "${var.cluster_name}-egress"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.aks.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "vpc_routing" {
  subnet_id      = data.azurerm_subnet.aks_subnet.id
  route_table_id = azurerm_route_table.aks_routing.id
}