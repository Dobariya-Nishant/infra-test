include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/aws/codedeploy"
}

dependency "alb" {
  config_path = "../alb"

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

dependency "cluster" {
  config_path = "../../ecs/cluster"

  # Optional: helpful for plan if ALB is not applied yet
  mock_outputs = {
    name             = "mock-cluster-name"
    id               = "mock-cluster-id"
    api_cp_name      = "mock-api-cp-name"
    frontend_cp_name = "mock-frontend-cp-name"
    frontend_cp_arn  = "arn:aws:autoscaling:us-east-1:111122223333:autoScalingGroup:fake-asg-id:autoScalingGroupName/mock-api-tg-arn"
    api_cp_arn       = "arn:aws:autoscaling:us-east-1:111122223333:autoScalingGroup:fake-asg-id:autoScalingGroupName/mock-default-tg-arn"
  }
}

dependency "api_service" {
  config_path = "../../ecs/service/api"

  # Optional: helpful for plan if ALB is not applied yet
  mock_outputs = {
    name = "mock-service-name"
    arn  = "arn:aws:autoscaling:us-east-1:111122223333:autoScalingGroup:fake-asg-id:autoScalingGroupName/mock-service-arn"
  }
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

inputs = {
  name         = "api-${local.env_vars.locals.project_name}"
  project_name = local.env_vars.locals.project_name
  environment  = local.env_vars.locals.environment

  cluster_name = dependency.cluster.outputs.name
  service_name = dependency.api_service.outputs.name

  alb_listener_arn        = dependency.alb.outputs.https_listener_arn
  blue_target_group_name  = dependency.alb.outputs.blue_api_tg_arn
  green_target_group_name = dependency.alb.outputs.green_api_tg_arn
}
