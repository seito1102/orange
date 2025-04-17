output "security_group_id" {
  description = "ALB security group id"
  value       = aws_security_group.alb_sg.id
}

output "listener_arn" {
  value = aws_lb_listener.listener.arn
}

output "test_listener_arn" {
  value = aws_lb_listener.test.arn
}

output "target_group1" {
  value = {
    name = aws_lb_target_group.alb_tg1.name
    arn = aws_lb_target_group.alb_tg1.arn
  }
  description = "ALB security group id"
}

output "target_group2" {
  value = {
    name = aws_lb_target_group.alb_tg2.name
    arn = aws_lb_target_group.alb_tg2.arn
  }
  description = "ALB security group id"
}