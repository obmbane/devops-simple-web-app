# Read the outputs of ../cluster from its state file
data "terraform_remote_state" "cluster" {
  backend = "local"

  config = {
    path = var.cluster_state_path
  }
}

locals {
  cluster = data.terraform_remote_state.cluster.outputs
}

# Connect to the cluster that ../cluster created
provider "kubernetes" {
  host                   = local.cluster.endpoint
  cluster_ca_certificate = local.cluster.cluster_ca_certificate
  client_certificate     = local.cluster.client_certificate
  client_key             = local.cluster.client_key
}
