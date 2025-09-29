output "lb_id" {
  description = "ID of the load balancer"
  value       = aws_lb.this.id
}

output "sg_id" {
  description = "Security group ID attached to the load balancer"
  value       = aws_security_group.this.id
}

output "default_tg_arn" {
  description = "ID of the load balancer"
  value       = aws_lb_target_group.default.arn
}

output "api_tg_arn" {
  description = "ID of the load balancer"
  value       = aws_lb_target_group.api_tg.arn
}