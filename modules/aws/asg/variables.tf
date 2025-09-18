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

variable "vpc_zone_identifier" {
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

variable "load_balancer_config" {
  description = "List of objects that define load balancer security group access (used to allow internal traffic from ALB/NLB)."
  type = list(object({
    sg_id    = string
    port     = number
    protocol = optional(string)
  }))
  default = []
}

variable "security_groups" {
  description = "Optional list of additional security group IDs to associate with the EC2 instances."
  type        = list(string)
  default     = []
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

variable "enable_public_ip_address" {
  description = "Associate a public IP address with launched EC2 instances. Useful for SSH or internet access."
  type        = bool
  default     = false
}

variable "user_data" {
  description = "Base64-encoded user data script to bootstrap EC2 instances (e.g., install packages, join ECS cluster)."
  type        = string
  default     = ""
}

# ===============
# ECS Integration
# ===============

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster to register the EC2 instances to. If set, ECS-specific AMI and user data will be used."
  type        = string
  default     = null
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

variable "target_group_arns" {
  description = "List of target group ARNs to register EC2 instances (used when attached to a Load Balancer)."
  type        = list(string)
  default     = []
}
