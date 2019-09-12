terraform {
  backend "azurerm" {
    key="k8s_setup/default.tfstate"
  }
}