# 시작 템플릿
resource "aws_launch_template" "quiz_web_lt" {
  name = "quiz-web-lt-${var.env}"
  image_id               = var.ami_id
  key_name               = "web-server-key" # 키 이름은 환경에 맞게 조정 필요
  vpc_security_group_ids = [var.web_sg_id]
  instance_type          = "t3.micro"
  
  tags = {
    "Name" = "quiz-web-lt-${var.env}"
    "env"  = var.env
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "quiz_asg" {
  name             = "quiz-asg-${var.env}"
  max_size         = 4
  min_size         = 2
  desired_capacity = 2

  health_check_grace_period = 300
  health_check_type         = "ELB"

  launch_template {
    id      = aws_launch_template.quiz_web_lt.id
    version = "$Latest"
  }

  vpc_zone_identifier = values(var.private_subnet_ids) # map을 list로 변환

  target_group_arns = [var.lb_target_group_arn]
  
  tags = [
    {
      key                 = "Name"
      value               = "quiz-asg-${var.env}"
      propagate_at_launch = true
    },
    {
      key                 = "env"
      value               = var.env
      propagate_at_launch = true
    }
  ]
}

# ASG 정책 (CPU 기반)
resource "aws_autoscaling_policy" "quiz_web_asg_policy" {
  autoscaling_group_name = aws_autoscaling_group.quiz_asg.name
  name                   = "quiz-web-asg-policy-${var.env}"
  policy_type            = "TargetTrackingScaling"
  
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 25.0
  }
}
