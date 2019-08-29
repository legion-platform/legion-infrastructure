########################################################
# Create Azure resource group for base AKS components
########################################################

resource "azurerm_resource_group" "k8s" {
  name     = var.name
  location = var.location
  tags     = var.tags
}