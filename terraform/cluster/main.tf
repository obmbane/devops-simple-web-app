resource "kind_cluster" "this" {
  name           = var.name
  node_image     = var.node_image
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      # One extra_port_mappings block per entry in var.port_mappings
      dynamic "extra_port_mappings" {
        for_each = var.port_mappings

        content {
          container_port = extra_port_mappings.value.container_port
          host_port      = extra_port_mappings.value.host_port
          listen_address = extra_port_mappings.value.listen_address
          protocol       = "TCP"
        }
      }
    }

    # One worker node block per worker_count
    dynamic "node" {
      for_each = range(var.worker_count)

      content {
        role = "worker"
      }
    }
  }
}
