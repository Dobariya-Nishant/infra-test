# infrastructure/terragrunt.hcl

remote_state {
  backend = "s3"
  config = {
    bucket         = "cardstudio-terraform-state-bucket"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "tf-backend-lock"
  }
}


