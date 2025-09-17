locals {
  name = "${var.name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}