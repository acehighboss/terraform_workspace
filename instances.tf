resource "aws_security_group" "quiz_bastion_sg" {
  vpc_id = aws_vpc.quiz_vpc.id
  name   = "quiz-bastion-sg"
  tags = {
    "Name" = "quiz-bastion-sg"
  }

  ingress {
    from_port   = 22
    to_port     = 22
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
resource "aws_security_group" "quiz_web_sg" {
  vpc_id = aws_vpc.quiz_vpc.id
  name   = "quiz-web-sg"
  tags = {
    "Name" = "quiz-web-sg"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
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
resource "aws_security_group" "quiz_db_sg" {
  vpc_id = aws_vpc.quiz_vpc.id
  name   = "quiz-db-sg"
  tags = {
    "Name" = "quiz-db-sg"
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.quiz_web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "quiz_bastion_ec2" {
  tags = {
    "Name" = "quiz-bastion-ec2"
  }

  ami           = "ami-00e73adb2e2c80366" # Ubuntu24 AMI 
  instance_type = "t3.micro"
  key_name      = "bastion-host-key"

  subnet_id              = aws_subnet.quiz_public_subnet_2c.id
  vpc_security_group_ids = [aws_security_group.quiz_bastion_sg.id]

}

resource "aws_instance" "quiz_web_ec2_11" {
  tags = {
    "Name" = "quiz-web-ec2"
  }

  ami                    = "ami-00e73adb2e2c80366" # Ubuntu24 AMI 
  instance_type          = "t3.micro"
  key_name               = "web-server-key"
  iam_instance_profile   = aws_iam_instance_profile.quiz_instance_profile.name
  subnet_id              = aws_subnet.quiz_private_subnet_2a_11.id
  vpc_security_group_ids = [aws_security_group.quiz_web_sg.id]
  # user_data              = file("tomcat-setting.sh")
  user_data = templatefile("tomcat-setting.sh.tpl", {
    DB_ADDRESS     = aws_db_instance.quiz_rds.address,
    DB_USERNAME    = var.db_username,
    DB_PASSWORD    = var.db_password,
    S3_BUCKET_NAME = aws_s3_bucket.quiz_s3_bucket.id
  })

}

resource "aws_db_subnet_group" "quiz_rds_subnet_group" {
  name = "quiz-rds-subnet-group"
  subnet_ids = [
    aws_subnet.quiz_private_subnet_2a_12.id,
    aws_subnet.quiz_private_subnet_2c_32.id
  ]

  tags = {
    Name = "quiz-rds-subnet-group"
  }
}

resource "aws_db_instance" "quiz_rds" {
  allocated_storage      = 20
  db_name                = "quizRds"
  engine                 = "mariadb"
  engine_version         = "11.4"
  instance_class         = "db.t4g.micro"
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mariadb11.4"
  skip_final_snapshot    = true
  apply_immediately      = true
  identifier             = "database-1"
  vpc_security_group_ids = [aws_security_group.quiz_db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.quiz_rds_subnet_group.id
}
