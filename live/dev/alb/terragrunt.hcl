include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/aws/alb"
}

dependency "vpc" {
  config_path = "../vpc"

  # Optional: helpful for plan if VPC is not applied yet
  mock_outputs = {
    vpc_id            = "vpc-mock"
    public_subent_ids = ["subnet-mock1", "subnet-mock2"]
  }
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

inputs = {
  name                 = "cardstudio"
  
  project_name         = local.env_vars.locals.project_name
  environment          = local.env_vars.locals.environment

  vpc_id               = dependency.vpc.outputs.vpc_id
  subnet_ids  = dependency.vpc.outputs.private_subent_ids

  enable_public_http = true
  internal = false
}
