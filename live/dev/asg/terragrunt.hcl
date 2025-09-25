include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/aws/asg"
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
  name                 = "cardstudio-asg"
  
  project_name         = local.env_vars.locals.project_name
  environment          = local.env_vars.locals.environment

  vpc_id               = dependency.vpc.outputs.vpc_id
  vpc_zone_identifier  = dependency.vpc.outputs.private_subent_ids
  
  # desired_capacity = 0
  # max_size = 0
  # min_size = 0

  ecs_cluster_name     = "cardstudio-ecs-dev"
}
