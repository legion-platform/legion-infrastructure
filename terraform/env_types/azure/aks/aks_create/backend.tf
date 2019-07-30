terraform {
  backend "gcs" {
    prefix  = "aks_create"
  }
}

# terraform {
#   backend "local" {
#     path = "../../../../_tfstate/state.tfstate"
#   }
# }