include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/aws/ecs/cluster"
}

dependency "vpc" {
  config_path = "../../vpc"

  # Optional: helpful for plan if VPC is not applied yet
  mock_outputs = {
    vpc_id             = "vpc-mock"
    public_subent_ids  = ["subnet-mock1", "subnet-mock2"]
    private_subent_ids = ["subnet-mock1", "subnet-mock2"]
  }
}

dependency "api_asg" {
  config_path = "../../asg/api"

  # Optional: helpful for plan if VPC is not applied yet
  mock_outputs = {
    template_id   = "lt-0123456789abcdef0"
    template_name = "mock-launch-template"
    asg_arn       = "arn:aws:autoscaling:us-east-1:111122223333:autoScalingGroup:fake-asg-id:autoScalingGroupName/mock-asg"
    asg_name      = "mock-asg"
    asg_id        = "fake-asg-id"
  }
}

dependency "client_asg" {
  config_path = "../../asg/client"

  # Optional: helpful for plan if VPC is not applied yet
  mock_outputs = {
    template_id   = "lt-0123456789abcdef0"
    template_name = "mock-launch-template"
    asg_arn       = "arn:aws:autoscaling:us-east-1:111122223333:autoScalingGroup:fake-asg-id:autoScalingGroupName/mock-asg"
    asg_name      = "mock-asg"
    asg_id        = "fake-asg-id"
  }
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

inputs = {
  name = "cardstudio-ecs"

  project_name = local.env_vars.locals.project_name
  environment  = local.env_vars.locals.environment

  vpc_id = dependency.vpc.outputs.vpc_id

  frontend_auto_scaling_group_arn = dependency.client_asg.outputs.asg_arn
  api_auto_scaling_group_arn = dependency.api_asg.outputs.asg_arn
}
