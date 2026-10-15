resource "kind_cluster" "this" {
  name            = var.cluster_name
  node_image      = var.node_image
  kubeconfig_path = var.kubeconfig_path
  wait_for_ready  = true

  kind_config {
    # Fixed by Kind's config file format, not settings
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      # localhost:<host_port> on your machine -> NodePort on this node
      extra_port_mappings {
        container_port = var.node_port
        host_port      = var.host_port
        protocol       = "TCP"
      }
    }

    # One worker block per worker_count
    dynamic "node" {
      for_each = range(var.worker_count)
      content {
        role = "worker"
      }
    }
  }
}
