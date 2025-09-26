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

# ==================
# Capacity Providers
# ==================

variable "frontend_auto_scaling_group_arn" {
  description = "List of ARNs of EC2 Auto Scaling Groups that will serve as capacity providers when using 'ec2' or 'combine' mode."
  type        = string
}

variable "api_auto_scaling_group_arn" {
  description = "List of ARNs of EC2 Auto Scaling Groups that will serve as capacity providers when using 'ec2' or 'combine' mode."
  type        = string
}