output "lb_target_group_arn" {
  description = "ARN of the LB target group"
  value       = aws_lb_target_group.quiz_lb_tg.arn
}
