# - aws_launch_template
# - aws_autoscaling_group
# - aws_autoscaling_policy

resource "null_resource" "quiz_web_ec2_time_wait" {
  depends_on = [aws_instance.quiz_web_ec2_11]
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/bastion-host-key.pem")
      host        = aws_instance.quiz_bastion_ec2.public_ip
    }

    inline = [
      "until curl -f http://${aws_instance.quiz_web_ec2_11.private_ip}:8080/boot/; do echo '웹 서비스 준비 중'; sleep 10;  done"
    ]
  }
}

resource "aws_ami_from_instance" "quiz_ami_instance" {
  name               = "quiz-web-ami"
  source_instance_id = aws_instance.quiz_web_ec2_11.id
  tags = {
    "Name" = "quiz-web-ami"
  }

  depends_on = [null_resource.quiz_web_ec2_time_wait]
}

resource "null_resource" "quiz_web_ec2_terminate" {
  depends_on = [aws_ami_from_instance.quiz_ami_instance]

  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_instance.quiz_web_ec2_11.id} --profile terraform-user"
  }
}

resource "aws_launch_template" "quiz_web_lt" {
  name = "quiz-web-lt"
  # image_id               = data.aws_ami.quiz_web_ami.id
  image_id               = aws_ami_from_instance.quiz_ami_instance.id
  key_name               = "web-server-key"
  vpc_security_group_ids = [aws_security_group.quiz_web_sg.id]
  instance_type          = "t3.micro"
  tags = {
    "Name" = "quiz-web-lt"
  }
}

resource "aws_autoscaling_group" "quiz_asg" {
  name             = "quiz-asg"
  max_size         = 4
  min_size         = 2
  desired_capacity = 2

  health_check_grace_period = 300
  health_check_type         = "ELB"

  launch_template {
    id      = aws_launch_template.quiz_web_lt.id
    version = "$Latest"
  }

  vpc_zone_identifier = [
    aws_subnet.quiz_private_subnet_2a_11.id,
    aws_subnet.quiz_private_subnet_2c_31.id
  ]

  target_group_arns = [aws_lb_target_group.quiz_lb_tg.arn]

}

resource "aws_autoscaling_policy" "quiz_web_asg_policy" {
  autoscaling_group_name = aws_autoscaling_group.quiz_asg.name
  name                   = "quiz-web-asg_policy"

  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 25.0
  }
}
