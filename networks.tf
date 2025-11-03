resource "aws_vpc" "quiz_vpc" {
  tags = {
    "Name" = "quiz-vpc"
  }
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "quiz_public_subnet_2a" {
  vpc_id     = aws_vpc.quiz_vpc.id
  cidr_block = cidrsubnet(aws_vpc.quiz_vpc.cidr_block, 8, 10)
  tags = {
    "Name" = "quiz-public-subnet-2a"
  }
  availability_zone = data.aws_availability_zones.quiz_az_names.names[0]

  map_public_ip_on_launch = true
}

resource "aws_subnet" "quiz_public_subnet_2c" {
  vpc_id     = aws_vpc.quiz_vpc.id
  cidr_block = cidrsubnet(aws_vpc.quiz_vpc.cidr_block, 8, 30)
  tags = {
    "Name" = "quiz-public-subnet-2c"
  }
  availability_zone       = data.aws_availability_zones.quiz_az_names.names[2]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "quiz_private_subnet_2a_11" {
  vpc_id     = aws_vpc.quiz_vpc.id
  cidr_block = cidrsubnet(aws_vpc.quiz_vpc.cidr_block, 8, 11)
  tags = {
    "Name" = "quiz-private-subnet-2a-11"
  }
  availability_zone = data.aws_availability_zones.quiz_az_names.names[0]
}

resource "aws_subnet" "quiz_private_subnet_2c_31" {
  vpc_id     = aws_vpc.quiz_vpc.id
  cidr_block = cidrsubnet(aws_vpc.quiz_vpc.cidr_block, 8, 31)
  tags = {
    "Name" = "quiz-private-subnet-2c-31"
  }
  availability_zone = data.aws_availability_zones.quiz_az_names.names[2]
}


resource "aws_subnet" "quiz_private_subnet_2a_12" {
  vpc_id     = aws_vpc.quiz_vpc.id
  cidr_block = cidrsubnet(aws_vpc.quiz_vpc.cidr_block, 8, 12)
  tags = {
    "Name" = "quiz-private-subnet-2a-12"
  }
  availability_zone = data.aws_availability_zones.quiz_az_names.names[0]
}

resource "aws_subnet" "quiz_private_subnet_2c_32" {
  vpc_id     = aws_vpc.quiz_vpc.id
  cidr_block = cidrsubnet(aws_vpc.quiz_vpc.cidr_block, 8, 32)
  tags = {
    "Name" = "quiz-private-subnet-2c-32"
  }
  availability_zone = data.aws_availability_zones.quiz_az_names.names[2]
}

resource "aws_internet_gateway" "quiz_igw" {
  vpc_id = aws_vpc.quiz_vpc.id
  tags = {
    "Name" = "quiz-igw"
  }
}

resource "aws_route_table" "quiz_public_rt" {
  vpc_id = aws_vpc.quiz_vpc.id

  tags = {
    "Name" = "quiz-public-rt"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.quiz_igw.id
  }
}

resource "aws_route_table" "quiz_private_rt" {
  vpc_id = aws_vpc.quiz_vpc.id
  tags = {
    "Name" = "quiz-private-rt"
  }
  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_instance.quiz_nat_ec2.primary_network_interface_id
  }
}


resource "aws_route_table_association" "quiz_public_rt_ass_2a" {
  subnet_id      = aws_subnet.quiz_public_subnet_2a.id
  route_table_id = aws_route_table.quiz_public_rt.id
}

resource "aws_route_table_association" "quiz_public_rt_ass_2c" {
  subnet_id      = aws_subnet.quiz_public_subnet_2c.id
  route_table_id = aws_route_table.quiz_public_rt.id
}

resource "aws_route_table_association" "quiz_private_rt_ass_2a_11" {
  subnet_id      = aws_subnet.quiz_private_subnet_2a_11.id
  route_table_id = aws_route_table.quiz_private_rt.id
}
resource "aws_route_table_association" "quiz_private_rt_ass_2a_12" {
  subnet_id      = aws_subnet.quiz_private_subnet_2a_12.id
  route_table_id = aws_route_table.quiz_private_rt.id
}
resource "aws_route_table_association" "quiz_private_rt_ass_2c_31" {
  subnet_id      = aws_subnet.quiz_private_subnet_2c_31.id
  route_table_id = aws_route_table.quiz_private_rt.id
}
resource "aws_route_table_association" "quiz_private_rt_ass_2c_32" {
  subnet_id      = aws_subnet.quiz_private_subnet_2c_32.id
  route_table_id = aws_route_table.quiz_private_rt.id
}

resource "aws_security_group" "quiz_nat_sg" {
  vpc_id = aws_vpc.quiz_vpc.id
  name   = "quiz-nat-sg"
  tags = {
    "Name" = "quiz-nat-sg"
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "quiz_nat_ec2" {
  tags = {
    "Name" = "quiz-nat-ec2"
  }
  ami = "ami-0eb63419e063fe627" # AMAZON LINUX AMI

  instance_type = "t3.micro"
  key_name      = "bastion-host-key"
  vpc_security_group_ids = [
    aws_security_group.quiz_nat_sg.id
  ]

  subnet_id         = aws_subnet.quiz_public_subnet_2a.id
  source_dest_check = false # 출발지/목적지 확인 하지마
  user_data         = file("nat-setting.sh")
}
