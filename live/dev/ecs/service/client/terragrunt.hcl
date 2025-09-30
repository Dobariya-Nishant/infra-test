include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../../modules/aws/ecs/service"
}

dependency "vpc" {
  config_path = "../../../vpc"

  # Optional: helpful for plan if VPC is not applied yet
  mock_outputs = {
    vpc_id             = "vpc-mock"
    public_subent_ids  = ["subnet-mock1", "subnet-mock2"]
    private_subent_ids = ["subnet-mock1", "subnet-mock2"]
  }
}

dependency "cluster" {
  config_path = "../../cluster"

  # Optional: helpful for plan if ALB is not applied yet
  mock_outputs = {
    name           = "mock-cluster-name"
    id             = "mock-cluster-id"
    client_cp_name = "mock-client-cp-name"
    client_cp_arn  = "arn:aws:autoscaling:us-east-1:111122223333:autoScalingGroup:fake-asg-id:autoScalingGroupName/mock-client-cp-arn"
    api_cp_name    = "mock-api-cp-name"
    api_cp_arn     = "arn:aws:autoscaling:us-east-1:111122223333:autoScalingGroup:fake-asg-id:autoScalingGroupName/mock-api-cp-arn"
  }
}


dependency "alb" {
  config_path = "../../../alb"

  # Optional: helpful for plan if ALB is not applied yet
  mock_outputs = {
    id                  = "mock-lb-id"
    sg_id               = "mock-sg-id"
    https_listener_arn  = "arn:aws:autoscaling:us-east-1:111122223333:autoScalingGroup:fake-asg-id:autoScalingGroupName/mock-https-listner-arn"
    blue_client_tg_arn  = "arn:aws:autoscaling:us-east-1:111122223333:autoScalingGroup:fake-asg-id:autoScalingGroupName/mock-blue-client-tg-arn"
    green_client_tg_arn = "arn:aws:autoscaling:us-east-1:111122223333:autoScalingGroup:fake-asg-id:autoScalingGroupName/mock-green-client-tg-arn"
    blue_api_tg_arn     = "arn:aws:autoscaling:us-east-1:111122223333:autoScalingGroup:fake-asg-id:autoScalingGroupName/mock-blue-api-tg-arn"
    green_api_tg_arn    = "arn:aws:autoscaling:us-east-1:111122223333:autoScalingGroup:fake-asg-id:autoScalingGroupName/mock-green-api-tg-arn"
  }
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

inputs = {
  name         = "client-sv"
  project_name = local.env_vars.locals.project_name
  environment  = local.env_vars.locals.environment

  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.private_subent_ids

  load_balancer_config = {
    sg_id            = dependency.alb.outputs.sg_id
    target_group_arn = dependency.alb.outputs.blue_client_tg_arn
    container_port   = 80
  }

  enable_public_http = true

  ecs_cluster_name = dependency.cluster.outputs.name
  ecs_cluster_id   = dependency.cluster.outputs.id

  desired_count = 1

  # capacity_provider_name = dependency.cluster.outputs.client_cp_name

  task = {
    name           = "nginx-dev"
    image_uri      = "nginx:latest"
    essential      = true
    cpu            = 256
    memory         = 512
    portMappings = [
      {
        containerPort = 80
        hostPort      = 80
      }
    ]
  }
}
