provider "aws" {
  version                 = "2.28.1"
  region                  = var.region_aws
  shared_credentials_file = var.aws_credentials_file
  profile                 = var.aws_profile
}

provider "google-beta" {
  version = "2.15.0"
  region  = var.region
  zone    = var.zone
  project = var.project_id
}

