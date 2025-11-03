output "ami_id" {
  description = "The ID of the created AMI"
  value       = aws_ami_from_instance.quiz_ami_instance.id
}

output "web_sg_id" {
  description = "The ID of the web security group"
  value       = aws_security_group.quiz_web_sg.id
}
