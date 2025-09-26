# ===========
# ECS Cluster
# ===========

# ECS Cluster with container insights enabled for better observability
resource "aws_ecs_cluster" "this" {
  name = local.name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = local.name
  }
}

# ==============================
# ECS Capacity Providers for EC2
# ==============================

# Creates capacity providers for each ASG passed in
resource "aws_ecs_capacity_provider" "api_cp" {
  name = "api-cp-${local.name}"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = var.api_auto_scaling_group_arn
    managed_termination_protection = "ENABLED"
    managed_draining               = "ENABLED"

    # Enables ECS to scale ASGs based on demand
    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 80
    }
  }

  tags = {
    Name = "api-cp-${local.name}"
  }
}

# Creates capacity providers for each ASG passed in
resource "aws_ecs_capacity_provider" "frontend_cp" {
  name = "frontend-cp-${local.name}"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = var.frontend_auto_scaling_group_arn
    managed_termination_protection = "ENABLED"
    managed_draining               = "ENABLED"

    # Enables ECS to scale ASGs based on demand
    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 80
    }
  }

  tags = {
    Name = "frontend-cp-${local.name}"
  }
}

# ========================================
# Attach Capacity Providers to ECS Cluster
# ========================================

# Mixed capacity: EC2 + FARGATE
resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = [
    aws_ecs_capacity_provider.api_cp.name,
    aws_ecs_capacity_provider.frontend_cp.arn,
    "FARGATE"
  ]

  # default stratergy is fargate
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }
}