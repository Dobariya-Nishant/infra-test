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
resource "aws_ecs_capacity_provider" "this" {
  count = length(var.auto_scaling_groups)

  name = "${local.name}-${count.index}"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = var.auto_scaling_groups[count.index]
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
    Name = "${local.name}-${count.index}"
  }
}

# ========================================
# Attach Capacity Providers to ECS Cluster
# ========================================

# Mixed capacity: EC2 + FARGATE
resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = concat(
    ["FARGATE"],
    try(aws_ecs_capacity_provider.this[*].name, [])
  )

  # Add EC2 providers only if they exist
  dynamic "default_capacity_provider_strategy" {
    for_each = try(aws_ecs_capacity_provider.this, [])

    content {
      capacity_provider = default_capacity_provider_strategy.value["name"]
      weight            = 1
      base              = 0
    }
  }

  # Always include FARGATE as default
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 0
  }
}

# ============
# ECS Services
# ============

# ECS Services based on above task definitions
resource "aws_ecs_service" "this" {
  count = length(aws_ecs_task_definition.this)

  name            = "${var.tasks[count.index].name}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this[count.index].arn
  desired_count   = var.tasks[count.index].desired_count

  network_configuration {
    subnets          = var.tasks[count.index].subnet_ids
    security_groups  = [aws_security_group.this[count.index].id]
    assign_public_ip = false
  }

  # Distributes tasks evenly across EC2 instances
  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }

  # Attach load balancer if defined
  dynamic "load_balancer" {
    for_each = try(var.tasks[count.index].load_balancer_config, [])
    content {
      target_group_arn = load_balancer.value["target_group_arn"]
      container_name   = var.tasks[count.index].name
      container_port   = load_balancer.value["container_port"]
    }
  }

  tags = {
    Name = "${var.tasks[count.index].name}-service"
  }
}

# ====================
# ECS Task Definitions
# ====================

# ECS Task Definitions for all tasks provided via `var.tasks`
resource "aws_ecs_task_definition" "this" {
  count = length(var.tasks)

  family       = var.tasks[count.index].name
  cpu          = var.tasks[count.index].cpu
  memory       = var.tasks[count.index].memory
  network_mode = "awsvpc"

  execution_role_arn = aws_iam_role.ecs_task_execution_role[0].arn
  task_role_arn      = lookup(var.tasks[count.index], "task_role_arn", null)

  container_definitions = jsonencode([
    {
      name         = var.tasks[count.index].name
      image        = var.tasks[count.index].image_uri
      essential    = var.tasks[count.index].essential
      environment  = lookup(var.tasks[count.index], "environment", [])
      portMappings = lookup(var.tasks[count.index], "portMappings", [])
      command      = var.tasks[count.index].command
    }
  ])

  tags = {
    Name = var.tasks[count.index].name
  }
}

# ==========================
# Auto Scaling (ECS Service)
# ==========================

# Register ECS Service as scalable
resource "aws_appautoscaling_target" "ecs_service" {
  count = length(aws_ecs_service.this)

  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this[count.index].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# CPU-based auto-scaling policy
resource "aws_appautoscaling_policy" "cpu_scaling" {
  count = length(aws_appautoscaling_target.ecs_service)

  name               = "${aws_ecs_service.this[count.index].name}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_service[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service[count.index].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 70.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

# Memory-based auto-scaling policy
resource "aws_appautoscaling_policy" "memory_scaling" {
  count = length(aws_appautoscaling_target.ecs_service)

  name               = "${aws_ecs_service.this[count.index].name}-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_service[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service[count.index].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 70.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

# ====================
# IAM Roles & Policies
# ====================

# IAM role trust policy for ECS container instances
data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# AWS managed policy for ECS service role
data "aws_iam_policy" "ecs_service_role_policy" {
  name = "AmazonEC2ContainerServiceRole"
}

# IAM role trust policy for ECS task execution role
data "aws_iam_policy_document" "ecs_task_execution_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# AWS managed policy for ECS task execution role
data "aws_iam_policy" "ecs_task_execution_role_policy" {
  name = "AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Execution IAM Role
resource "aws_iam_role" "ecs_task_execution_role" {
  count = var.tasks != null ? 1 : 0

  name               = "${local.name}-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json

  tags = {
    Name = "${local.name}-task-execution-role"
  }
}

# Attach managed execution policy to role
resource "aws_iam_role_policy_attachment" "task_execution_policy_attach" {
  count = var.tasks != null ? 1 : 0

  role       = aws_iam_role.ecs_task_execution_role[0].name
  policy_arn = data.aws_iam_policy.ecs_task_execution_role_policy.arn
}

# ============================
# Security Group (ECS Service)
# ============================

resource "aws_security_group" "this" {
  count = length(var.tasks)

  name        = "${var.tasks[count.index].name}-sg"
  description = "${var.tasks[count.index].name} task`s Security group"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.tasks[count.index].enable_public_http == true ? [1] : []
    content {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP"
    }
  }

  dynamic "ingress" {
    for_each = var.tasks[count.index].enable_public_https == true ? [1] : []
    content {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTPS"
    }
  }

  dynamic "ingress" {
    for_each = try(var.tasks[count.index].load_balancer_config, [])
    content {
      from_port       = ingress.value["container_port"]
      to_port         = ingress.value["container_port"]
      protocol        = "tcp"
      security_groups = [ingress.value["sg_id"]]
      description     = "load balancer security group"
    }
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.tasks[count.index].name}-sg"
  }
}