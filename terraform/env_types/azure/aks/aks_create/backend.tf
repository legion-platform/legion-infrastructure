terraform {
  backend "azurerm" {
    key="aks_create/default.tfstate"
  }
}