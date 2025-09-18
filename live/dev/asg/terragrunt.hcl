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
    vpc_id         = "vpc-mock"
    public_subent_ids = ["subnet-mock1", "subnet-mock2"]
  }
}

inputs = {
  project_name         = "node-api"
  name                 = "node-api-asg"
  environment          = "dev"

  vpc_id               = dependency.vpc.outputs.vpc_id
  vpc_zone_identifier  = dependency.vpc.outputs.public_subent_ids

  ecs_cluster_name = "node-ecs-dev"
  enable_public_ssh    = true
}
