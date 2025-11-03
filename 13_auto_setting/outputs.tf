output "quiz_rds_address" {
  value = aws_db_instance.quiz_rds.address
}

output "quiz_bastion_public_ip" {
  value = aws_instance.quiz_bastion_ec2.public_ip
}

output "quiz_web_private_ip" {
  value = aws_instance.quiz_web_ec2_11.private_ip
}

output "quiz_lb_dns_name" {
  value = aws_lb.quiz_lb.dns_name
}