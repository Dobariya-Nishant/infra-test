output "name" {
  value = aws_ecs_cluster.this.name
}

output "id" {
  value = aws_ecs_cluster.this.id
}

output "api_cp_name" {
  value = try(aws_ecs_capacity_provider.api_cp[0].name, null)
}

output "api_cp_arn" {
  value = try(aws_ecs_capacity_provider.api_cp[0].arn, null)
}

output "client_cp_name" {
  value = try(aws_ecs_capacity_provider.client_cp[0].name, null)
}

output "client_cp_arn" {
  value = try(aws_ecs_capacity_provider.client_cp[0].arn, null)
}