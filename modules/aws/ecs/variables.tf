# ==========================
# Core Project Configuration
# ==========================

variable "project_name" {
  description = "The name of the project. Used consistently for naming, tagging, and organizational purposes across resources."
  type        = string
}

variable "name" {
  description = "Base name identifier applied to all resources (e.g., cluster name, IAM roles, etc.) for consistent resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment identifier (e.g., dev, staging, prod). Used for environment-specific tagging and naming."
  type        = string
}

# ==========
# Networking
# ==========

variable "vpc_id" {
  description = "The ID of the existing VPC in which ECS and related resources will be deployed."
  type        = string
}

# ======================
# ECS Task Configuration
# ======================

variable "tasks" {
  description = <<-DESC
    A list of ECS task configurations. Each object represents a single ECS service configuration with
    support for optional load balancer integration, IAM task roles, custom port mappings, and more.
  DESC
  type = list(object({
    name                = string                  // Name of the ECS task definition and service
    image_uri           = string                  // Container image URI from ECR or external registry
    essential           = optional(bool)          // Whether the container is essential to the task
    container_port      = optional(number)        // Container port to expose (used for service discovery or load balancer)
    task_role_arn       = optional(string)        // IAM role ARN the task assumes for permissions
    cpu                 = optional(number)        // CPU units reserved for the task
    memory              = optional(number)        // Memory (in MiB) reserved for the task
    enable_public_http  = optional(bool)          // Enable HTTP access via ALB
    enable_public_https = optional(bool)          // Enable HTTPS access via ALB
    subnet_ids          = list(string)            // Subnets in which to deploy the task/service
    command             = optional(list(string))  // Override container entrypoint command
    load_balancer_config = list(object({ // Load balancer settings for the ECS service
      sg_id            = string                   // Security Group ID for the load balancer
      target_group_arn = string                   // ARN of the target group the container is registered to
      container_port   = number                   // Port exposed on the container to register in the target group
    }))
    environment = optional(list(object({ // List of environment variables for the container
      name  = string
      value = string
    })))
    portMappings = optional(list(object({ // List of port mappings for container networking
      containerPort = number              // Port exposed inside the container
      hostPort      = number              // Host port (typically 0 unless EC2 mode is used)
    })))
    desired_count = number // Desired number of task replicas (ECS service count)
  }))
  default = []
}

# ==========================
# Capacity Provider Settings
# ==========================

variable "auto_scaling_groups" {
  description = "List of ARNs of EC2 Auto Scaling Groups that will serve as capacity providers when using 'ec2' or 'combine' mode."
  type        = list(string)
  default     = []
}
