include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/aws/ecs/service"
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

dependency "cluster" {
  config_path = "../cluster"

  # Optional: helpful for plan if ALB is not applied yet
  mock_outputs = {
    cluster_name          = "lt-0123456789abcdef0"
    cluster_id            = "0123456789abcdef0"
    api_cp_name          = "mock-api-cp-name"
    frontend_cp_name = "mock-frontend-cp-name"
    frontend_cp_arn     = "arn:aws:autoscaling:us-east-1:111122223333:autoScalingGroup:fake-asg-id:autoScalingGroupName/mock-api-tg-arn"
    api_cp_arn = "arn:aws:autoscaling:us-east-1:111122223333:autoScalingGroup:fake-asg-id:autoScalingGroupName/mock-default-tg-arn"
  }
}


dependency "alb" {
  config_path = "../../alb"

  # Optional: helpful for plan if ALB is not applied yet
  mock_outputs = {
    lb_id          = "lt-0123456789abcdef0"
    sg_id          = "mock-launch-template"
    default_tg_arn = "arn:aws:autoscaling:us-east-1:111122223333:autoScalingGroup:fake-asg-id:autoScalingGroupName/mock-default-tg-arn"
    api_tg_arn     = "arn:aws:autoscaling:us-east-1:111122223333:autoScalingGroup:fake-asg-id:autoScalingGroupName/mock-api-tg-arn"
  }
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

inputs = {
  name         = "frontend-sv"
  project_name = local.env_vars.locals.project_name
  environment  = local.env_vars.locals.environment

  vpc_id             = dependency.vpc.outputs.vpc_id
  subnet_ids         = dependency.vpc.outputs.private_subent_ids
  enable_public_http = true
  load_balancer_config = {
    sg_id            = dependency.alb.outputs.sg_id
    target_group_arn = dependency.alb.outputs.default_tg_arn
    container_port   = 80
  }

  ecs_cluster_name     = dependency.cluster.outputs.cluster_name
  ecs_cluster_id     = dependency.cluster.outputs.cluster_id

  desired_count = 1

  capacity_provider_name = dependency.cluster.outputs.frontend_cp_name

  task = {
      name           = "nginx-dev"
      image_uri      = "nginx:latest"
      essential      = true
      container_port = 80
      cpu            = 512
      memory         = 800
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
}
