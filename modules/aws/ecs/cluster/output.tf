output "cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "api_cp_name" {
  value = aws_ecs_capacity_provider.api_cp.name
}

output "api_cp_arn" {
  value = aws_ecs_capacity_provider.api_cp.arn
}

output "frontend_cp_arn" {
  value = aws_ecs_capacity_provider.frontend_cp.arn
}

output "frontend_cp_name" {
  value = aws_ecs_capacity_provider.frontend_cp.name
}