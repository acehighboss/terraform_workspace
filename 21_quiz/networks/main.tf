resource "aws_vpc" "quiz_vpc" {
  tags = {
    "Name" = "${var.env}-vpc"
  }
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

}

data "aws_availability_zones" "quiz_az_names" {
  state = "available"
}

resource "aws_subnet" "quiz_public_subnets" {
  for_each = var.public_subnets
  vpc_id     = aws_vpc.quiz_vpc.id
  cidr_block = cidrsubnet(aws_vpc.quiz_vpc.cidr_block, 8, each.value) 
  tags = {
    "Name" = "${var.env}-${each.key}"
  }
  availability_zone = each.value == 10 ?  data.aws_availability_zones.quiz_az_names.names[0] : data.aws_availability_zones.quiz_az_names.names[2]
  map_public_ip_on_launch = true
}
resource "aws_subnet" "quiz_private_subnets" {
  for_each = var.private_subnets
  vpc_id     = aws_vpc.quiz_vpc.id
  cidr_block = cidrsubnet(aws_vpc.quiz_vpc.cidr_block, 8, each.value) 
  tags = {
    "Name" = "${var.env}-${each.key}"
  }
  availability_zone = floor(each.value / 10) == 1 ?  data.aws_availability_zones.quiz_az_names.names[0] : data.aws_availability_zones.quiz_az_names.names[2]

}

resource "aws_internet_gateway" "quiz_igw" {
  vpc_id = aws_vpc.quiz_vpc.id
  tags = {
    "Name" = "${var.env}-igw"
  }
}

resource "aws_route_table" "quiz_public_rt" {
  vpc_id = aws_vpc.quiz_vpc.id
  tags = {
    "Name" = "${var.env}-public-rt"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.quiz_igw.id
  }
}

resource "aws_route_table" "quiz_private_rt" {
  vpc_id = aws_vpc.quiz_vpc.id
  tags = {
    "Name" = "${var.env}-private-rt"
  }
  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_instance.quiz_nat_ec2.primary_network_interface_id
  }
}

resource "aws_route_table_association" "quiz_public_rt_ass" {
  for_each = var.public_subnets
  subnet_id      = aws_subnet.quiz_public_subnets[each.key].id
  route_table_id = aws_route_table.quiz_public_rt.id
}

resource "aws_route_table_association" "quiz_private_rt_ass" {
  for_each = var.private_subnets
  subnet_id      = aws_subnet.quiz_private_subnets[each.key].id
  route_table_id = aws_route_table.quiz_private_rt.id
}

resource "aws_security_group" "quiz_nat_sg" {
  vpc_id = aws_vpc.quiz_vpc.id
  name   = "${var.env}-nat-sg"
  tags = {
    "Name" = "${var.env}-nat-sg"
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
    "Name" = "${var.env}-nat-ec2"
  }
  ami = "ami-0eb63419e063fe627" # AMAZON LINUX AMI

  instance_type = "t3.micro"
  key_name      = "bastion-host-key"
  vpc_security_group_ids = [
    aws_security_group.quiz_nat_sg.id
  ]

  subnet_id         = aws_subnet.quiz_public_subnets["public-subnet-10"].id
  source_dest_check = false # 출발지/목적지 확인 하지마
  user_data         = file("../networks/nat-setting.sh")
}
