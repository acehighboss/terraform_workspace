# LB용 보안 그룹
resource "aws_security_group" "quiz_lb_sg" {
  vpc_id = var.vpc_id
  name   = "quiz-lb-sg-${var.env}"
  tags = {
    "Name" = "quiz-lb-sg-${var.env}"
    "env"  = var.env
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

# Application Load Balancer
resource "aws_lb" "quiz_lb" {
  name               = "quiz-lb-${var.env}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.quiz_lb_sg.id]
  subnets            = values(var.public_subnet_ids) # map을 list로 변환

  enable_deletion_protection = false

  tags = {
    "Name" = "quiz-lb-${var.env}"
    "env"  = var.env
  }
}

# LB 타겟 그룹
resource "aws_lb_target_group" "quiz_lb_tg" {
  vpc_id   = var.vpc_id
  name     = "quiz-lb-tg-${var.env}"
  port     = 8080
  protocol = "HTTP"

  health_check {
    path = "/boot/"
  }
  stickiness {
    type = "lb_cookie"
  }
  tags = {
    "env" = var.env
  }
}

# LB 리스너
resource "aws_lb_listener" "quiz_lb_listener_80" {
  load_balancer_arn = aws_lb.quiz_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.quiz_lb_tg.arn
  }
}
