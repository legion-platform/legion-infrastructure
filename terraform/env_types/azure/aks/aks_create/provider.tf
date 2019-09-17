provider "azurerm" {
  version         = "= 1.33.1"
}

provider "aws" {
  version                 = "= 2.28.1"
  region                  = var.aws_region
  shared_credentials_file = var.aws_credentials_file
  profile                 = var.aws_profile
}

provider "random" {
  version = "= 2.2.0"
}

provider "local" {
  version = "= 1.3.0"
}

provider "null" {
  version = "= 2.1.2"
}

provider "http" {
  version = "= 1.1.1"
}

provider "tls" {
  version = "= 2.1.0"
}