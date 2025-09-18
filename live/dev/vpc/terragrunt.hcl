include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/aws/vpc"
}

inputs = {
  project_name = "node-api"
  environment = "dev"
  name       = "node"
  cidr_block = "10.0.0.0/16"
  public_subnets = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
  private_subnets = ["10.0.10.0/24","10.0.11.0/24","10.0.12.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
