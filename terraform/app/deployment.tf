locals {
  labels = {
    "app.kubernetes.io/name" = var.app_name
  }
}

resource "kubernetes_deployment_v1" "app" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace_v1.app.metadata[0].name
    labels    = local.labels
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = local.labels
    }

    template {
      metadata {
        labels = local.labels

        # nginx only reads its config at startup. Changing the ConfigMap changes
        # this hash, which rolls out new pods that pick up the new config.
        annotations = {
          "checksum/nginx-config" = sha256(local.nginx_conf)
        }
      }

      spec {
        # Only run on worker nodes. This also stops the spread rule below
        # from counting the control-plane as a place pods could go.
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "node-role.kubernetes.io/control-plane"
                  operator = "DoesNotExist"
                }
              }
            }
          }
        }

        # Spread pods evenly across workers, so losing one node doesn't take down the app.
        # A worker that is still starting up counts too, so pods wait for it
        # instead of all landing on whichever worker was ready first.
        topology_spread_constraint {
          max_skew           = 1
          topology_key       = "kubernetes.io/hostname"
          when_unsatisfiable = "DoNotSchedule"

          label_selector {
            match_labels = local.labels
          }
        }

        container {
          name  = "nginx"
          image = "${var.image_repository}:${var.image_tag}"

          # Port 80 is fixed: it must match "listen 80" in nginx/default.conf
          port {
            name           = "http"
            container_port = 80
          }

          resources {
            requests = var.resources.requests
            limits   = var.resources.limits
          }

          # Only send traffic to the pod once nginx answers
          readiness_probe {
            http_get {
              path = var.probes.path
              port = "http"
            }
            initial_delay_seconds = var.probes.readiness.initial_delay_seconds
            period_seconds        = var.probes.readiness.period_seconds
            failure_threshold     = var.probes.readiness.failure_threshold
          }

          # Restart the container if nginx stops answering
          liveness_probe {
            http_get {
              path = var.probes.path
              port = "http"
            }
            initial_delay_seconds = var.probes.liveness.initial_delay_seconds
            period_seconds        = var.probes.liveness.period_seconds
            failure_threshold     = var.probes.liveness.failure_threshold
          }

          # Keep serving for a few seconds after deletion starts, so every node
          # stops routing to this pod before nginx is told to stop
          lifecycle {
            pre_stop {
              exec {
                command = ["sleep", "5"]
              }
            }
          }

          # Mount the ConfigMap over the image's /etc/nginx/conf.d
          volume_mount {
            name       = "nginx-config"
            mount_path = "/etc/nginx/conf.d"
            read_only  = true
          }
        }

        volume {
          name = "nginx-config"
          config_map {
            name = kubernetes_config_map_v1.nginx.metadata[0].name
          }
        }
      }
    }
  }
}
