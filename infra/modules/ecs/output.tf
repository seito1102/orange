output "cluster_name" {
  description = "cluster_name"
  value       = aws_ecs_cluster.app_cluster.name
}

output "service_name" {
  description = "service_name"
  value       = aws_ecs_service.service.name
}