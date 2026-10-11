locals {
  nginx_conf = file("${path.module}/nginx/default.conf")
}

# Overrides the default nginx config baked into the image
resource "kubernetes_config_map_v1" "nginx" {
  metadata {
    name      = "${var.app_name}-nginx"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
  }

  data = {
    "default.conf" = local.nginx_conf
  }
}
