output "cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "cluster_id" {
  value = aws_ecs_cluster.this.id
}

output "api_cp_name" {
  value = try(aws_ecs_capacity_provider.api_cp[0].name, null)
}

output "api_cp_arn" {
  value = try(aws_ecs_capacity_provider.api_cp[0].arn, null)
}

output "frontend_cp_arn" {
  value = try(aws_ecs_capacity_provider.frontend_cp[0].arn, null)
}

output "frontend_cp_name" {
  value = try(aws_ecs_capacity_provider.frontend_cp[0].name, null)
}