module "namespace" {
  source = "../../modules/team-namespace"

  environment = "prod"
  name        = "team-catalog"
  team        = "catalog"
}

module "web_app" {
  source = "../../modules/web-app"

  image     = "docker.io/olly007/simple-web-app:v1"
  name      = "simple-web-app"
  namespace = module.namespace.name
  replicas  = 2

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
