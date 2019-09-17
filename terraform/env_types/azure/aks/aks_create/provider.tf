provider "azurerm" {
  version         = "= 1.33.1"
}

provider "aws" {
  version                 = "~> 2.25"
  region                  = var.aws_region
  shared_credentials_file = var.aws_credentials_file
  profile                 = var.aws_profile
}

provider "random" {
  version = "~> 2.2"
}

provider "local" {
  version = "~> 1.3"
}

provider "null" {
  version = "~> 2.1"
}

provider "http" {
  version = "~> 1.1"
}

provider "tls" {
  version = "~> 2.1"
}