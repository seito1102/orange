output "security_group_id" {
  description = "ALB security group id"
  value       = aws_security_group.alb_sg.id
}

output "target_group_arn" {
  description = "ALB target_group_arn"
  value       = aws_lb_target_group.alb_tg1.arn
}