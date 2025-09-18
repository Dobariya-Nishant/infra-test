include {
  path = find_in_parent_folders("root.hcl")
}

terraform { 
  source = "../../../modules/aws/ecs"
}

dependency "vpc" {
  config_path = "../vpc"

  # Optional: helpful for plan if VPC is not applied yet
  mock_outputs = {
    vpc_id         = "vpc-mock"
    public_subent_ids = ["subnet-mock1", "subnet-mock2"]
    private_subent_ids = ["subnet-mock1", "subnet-mock2"]
  }
}

dependency "asg" {
  config_path = "../asg"

  # Optional: helpful for plan if VPC is not applied yet
  mock_outputs = {
    template_id     = "lt-0123456789abcdef0"
    template_name   = "mock-launch-template"
    asg_arn         = "arn:aws:autoscaling:us-east-1:111122223333:autoScalingGroup:fake-asg-id:autoScalingGroupName/mock-asg"
    asg_name        = "mock-asg"
    asg_id          = "fake-asg-id"
  }
}

inputs = {
  project_name         = "node-api"
  name                 = "node-ecs"
  environment          = "dev"

  vpc_id               = dependency.vpc.outputs.vpc_id

  auto_scaling_groups = [dependency.asg.outputs.asg_arn]


  tasks = [
    {
      name="nginx-dev"
      image_uri="nginx:latest"
      essential = true
      container_port = 80
      enable_public_http = true
      cpu = 512
      memory = 800
      subnet_ids = dependency.vpc.outputs.private_subent_ids
      portMappings = [
        { 
          containerPort = 80             
          hostPort      = 80             
        }
      ]
      desired_count = 2
    }
  ]
}
