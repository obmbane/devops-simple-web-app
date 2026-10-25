# Read the connection details of the existing cluster from ../cluster's state.
# This configuration uses the cluster but never manages it.
data "terraform_remote_state" "cluster" {
  backend = "local"

  config = {
    path = var.cluster_state_path
  }
}

locals {
  cluster = data.terraform_remote_state.cluster.outputs
}

provider "kubernetes" {
  host                   = local.cluster.endpoint
  cluster_ca_certificate = local.cluster.cluster_ca_certificate
  client_certificate     = local.cluster.client_certificate
  client_key             = local.cluster.client_key
}

