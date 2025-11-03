resource "aws_security_group" "quiz_web_sg" {
  vpc_id = var.vpc_id
  name   = "${var.env}-web-sg"
  tags = {
    "Name" = "${var.env}-web-sg"
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
  vpc_id = var.vpc_id
  name   = "${var.env}-db-sg"
  tags = {
    "Name" = "${var.env}-db-sg"
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

resource "aws_security_group" "quiz_bastion_sg" {
  vpc_id = var.vpc_id
  name   = "${var.env}-bastion-sg"
  tags = {
    "Name" = "${var.env}-bastion-sg"
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "quiz_bastion" {
  tags = {
    "Name" = "${var.env}-bastion"
  }

  ami           = "ami-00e73adb2e2c80366" # Ubuntu24 AMI 
  instance_type = "t3.micro"
  key_name      = "bastion-host-key"

  subnet_id              = var.public_subnet_ids["public-subnet-30"]
  vpc_security_group_ids = [aws_security_group.quiz_bastion_sg.id]

}

resource "aws_instance" "quiz_webs" {
  for_each = {
    for key, value in var.private_subnet_ids : 
    key => value if key == "private-subnet-11" || key == "private-subnet-31"
  }

  tags = {
    "Name" = "${var.env}-webs"
  }

  ami           = "ami-00e73adb2e2c80366" # Ubuntu24 AMI 
  instance_type = "t3.micro"
  key_name      = "web-server-key"

  subnet_id              = each.value
  vpc_security_group_ids = [aws_security_group.quiz_web_sg.id]
  user_data              = file("../instances/tomcat-setting.sh")
}

resource "aws_db_subnet_group" "quiz_rds_subnet_group" {
  name = "${var.env}-rds-subnet-group"
  subnet_ids = [
    var.private_subnet_ids["private-subnet-12"],
    var.private_subnet_ids["private-subnet-32"]
  ]

  tags = {
    Name = "${var.env}-rds-subnet-group"
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
  identifier             = "database-${var.env}"
  vpc_security_group_ids = [aws_security_group.quiz_db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.quiz_rds_subnet_group.id
}
