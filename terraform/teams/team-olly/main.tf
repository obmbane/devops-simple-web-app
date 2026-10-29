module "namespace" {
  source = "../../modules/team-namespace"

  environment = "prod"
  name        = "team-olly"
  team        = "olly"
  resource_quota = {
    node_ports = 1
    }

}

module "web_app" {
  source = "../../modules/web-app"

  image        = "docker.io/olly007/simple-web-app:v2"
  name         = "devops-journey-app"
  namespace    = module.namespace.name
  node_port    = 30080
  replicas     = 2
  service_type = "NodePort"

  resources = {
    limits = {
      cpu    = "200m"
      memory = "128Mi"
    }
    requests = {
      cpu    = "50m"
      memory = "32Mi"
    }
  }
}
