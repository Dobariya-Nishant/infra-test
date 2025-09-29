# ==========================
# Core Project Configuration
# ==========================

variable "project_name" {
  description = "Name of the overall project. Used for consistent naming and tagging across all resources."
  type        = string
}

variable "name" {
  description = "Base name used as an identifier for all resources (e.g., key name, launch template name, etc.)."
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod). Used for tagging and naming consistency."
  type        = string
}

# ==========
# Networking
# ==========

variable "vpc_id" {
  description = "The VPC ID where resources like EC2, security groups, etc. will be deployed."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Auto Scaling Group to launch instances in. Determines availability zones."
  type        = list(string)
}

# ====================
# Security Group Rules
# ====================

variable "enable_public_https" {
  description = "Allow inbound traffic on port 443 (HTTPS) from the internet."
  type        = bool
  default     = false
}

variable "enable_public_http" {
  description = "Allow inbound traffic on port 80 (HTTP) from the internet."
  type        = bool
  default     = false
}

variable "enable_public_ssh" {
  description = "Allow inbound SSH access (port 22) from any IP (0.0.0.0/0). Use with caution in production."
  type        = bool
  default     = false
}

variable "enable_ssh_from_current_ip" {
  description = "Allow SSH access (port 22) only from your current public IP."
  type        = bool
  default     = false
}

# =================
# EC2 Configuration
# =================

variable "instance_type" {
  description = "EC2 instance type to launch (e.g., t3.micro, m5.large)."
  type        = string
  default     = "t2.micro"
}

variable "ebs_type" {
  description = "EBS volume type (e.g., gp2, gp3, io1) attached to EC2 instances."
  type        = string
  default     = "gp2"
}

variable "ebs_size" {
  description = "Size (in GB) of the root EBS volume attached to EC2 instances."
  type        = string
  default     = 30
}

# ===============
# ECS Integration
# ===============

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster to register the EC2 instances to. If set, ECS-specific AMI and user data will be used."
  type        = string
}

# ==================
# Auto Scaling Group
# ==================

variable "desired_capacity" {
  description = "Number of instances the Auto Scaling Group should launch initially."
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances the Auto Scaling Group can scale up to."
  type        = number
  default     = 6
}

variable "min_size" {
  description = "Minimum number of instances the Auto Scaling Group should maintain."
  type        = number
  default     = 1
}
