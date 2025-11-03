resource "aws_security_group" "quiz_lb_sg" {
  vpc_id = aws_vpc.quiz_vpc.id
  name   = "quiz-lb-sg"
  tags = {
    "Name" = "quiz-lb-sg"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_lb" "quiz_lb" {
  name               = "quiz-lb"
  internal           = false # 인터넷 경계
  load_balancer_type = "application"
  security_groups    = [aws_security_group.quiz_lb_sg.id]
  subnets = [
    aws_subnet.quiz_public_subnet_2a.id,
    aws_subnet.quiz_public_subnet_2c.id
  ]

  enable_deletion_protection = false

  tags = {
    "Name" = "quiz-lb"
  }
}

resource "aws_lb_target_group" "quiz_lb_tg" {
  vpc_id   = aws_vpc.quiz_vpc.id
  name     = "quiz-lb-tg"
  port     = 8080
  protocol = "HTTP"

  health_check {
    path = "/boot/"
  }
  stickiness {
    type = "lb_cookie"
  }
}

# resource "aws_lb_target_group_attachment" "quiz_tg_attach_11" {
#   target_group_arn = aws_lb_target_group.quiz_lb_tg.arn
#   target_id        = aws_instance.quiz_web_ec2_11.id
#   port             = 8080
# }
# resource "aws_lb_target_group_attachment" "quiz_tg_attach_31" {
#   target_group_arn = aws_lb_target_group.quiz_lb_tg.arn
#   target_id        = aws_instance.quiz_web_ec2_31.id
#   port             = 8080
# }

resource "aws_lb_listener" "quiz_lb_listener_80" {
  load_balancer_arn = aws_lb.quiz_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.quiz_lb_tg.arn
  }
}