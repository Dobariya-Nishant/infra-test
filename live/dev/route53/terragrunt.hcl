include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/aws/route53"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

inputs = {
  name               = "activatree"
  project_name       = local.env_vars.locals.project_name
  environment        = local.env_vars.locals.environment
  domain_name        = local.env_vars.locals.domain_name
}
