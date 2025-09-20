output "task_definition_arn" {
  value = aws_ecs_task_definition.this.arn
}

output "ecs_service_name" {
  value = aws_ecs_service.this.name
}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.this.id
}

output "target_group_arn" {
  value       = aws_lb_target_group.this.arn
}
