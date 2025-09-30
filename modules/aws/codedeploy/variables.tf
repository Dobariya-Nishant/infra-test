# ==========================
# Core Project Variables
# ==========================

variable "project_name" {
  description = "Top-level project identifier (e.g., ecommerce, fintech)."
  type        = string
}

variable "name" {
  description = "Base name for resources (e.g., orders-service, payments-api)."
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)."
  type        = string
}

# ==========================
# ECS Configuration
# ==========================

variable "cluster_name" {
  description = "ECS cluster name where the service runs."
  type        = string
}

variable "service_name" {
  description = "ECS service name managed by CodeDeploy."
  type        = string
}

# ==========================
# Load Balancer Configuration
# ==========================

variable "alb_listener_arn" {
  description = "ARN of the ALB listener used for traffic shifting."
  type        = string
}

variable "blue_target_group_name" {
  description = "Name of the blue (active) target group."
  type        = string
}

variable "green_target_group_name" {
  description = "Name of the green (test) target group."
  type        = string
}
