module "namespace" {
  source = "../../modules/team-namespace"

  environment = "prod"
  name        = "team-catalog"
  team        = "catalog"
}
