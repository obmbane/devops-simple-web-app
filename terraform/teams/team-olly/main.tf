module "namespace" {
  source = "../../modules/team-namespace"

  environment = "prod"
  name        = "simple-web-app"
  team        = "olly"
}
