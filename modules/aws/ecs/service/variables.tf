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

variable "enable_public_http" {
  description = "The ID of the existing VPC in which ECS and related resources will be deployed."
  type        = bool
  default     = false
}

variable "enable_public_https" {
  description = "The ID of the existing VPC in which ECS and related resources will be deployed."
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "Subnets in which to deploy the task/service."
  type        = list(string)
}


# =========================
# ECS Service Configuration
# =========================

variable "desired_count" {
  description = "Desired number of task replicas (ECS service count)"
  type        = number
}

variable "capacity_provider_name" {
  description = "Desired number of task replicas (ECS service count)"
  type        = string
  default     = null
}

variable "load_balancer_config" {
  description = "Configuration of the existing ALB in which ECS service get loadbalanced."
  type = object({             // Load balancer settings for the ECS service
    sg_id            = string // Security Group ID for the load balancer
    target_group_arn = string // ARN of the target group the container is registered to
    container_port   = number // Port exposed on the container to register in the target group
  })
}

# ================
# ECS Cluster Info
# ================

variable "ecs_cluster_name" {
  description = "The ID of the existing VPC in which ECS and related resources will be deployed."
  type        = string
}

variable "ecs_cluster_id" {
  description = "The ID of the existing VPC in which ECS and related resources will be deployed."
  type        = string
}

# ======================
# ECS Task Configuration
# ======================

variable "task" {
  description = <<-DESC
    ECS task configuration. object represents a single ECS service configuration with
    support for optional load balancer integration, IAM task roles, custom port mappings, and more.
  DESC
  type = object({
    name          = string                 // Name of the ECS task definition and service
    image_uri     = string                 // Container image URI from ECR or external registry
    task_role_arn = optional(string)       // IAM role ARN the task assumes for permissions
    cpu           = optional(number)       // CPU units reserved for the task
    memory        = optional(number)       // Memory (in MiB) reserved for the task
    essential = optional(bool)   
    command       = optional(list(string)) // Override container entrypoint command
    environment = optional(list(object({   // List of environment variables for the container
      name  = string
      value = string
    })))
    portMappings = list(object({ // List of port mappings for container networking
      containerPort = number     // Port exposed inside the container
      hostPort      = number     // Host port (typically 0 unless EC2 mode is used)
    }))
  })
}


