# ----------------------------------------------------------------
# 1. Terraform 및 AWS Provider 설정
# ----------------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# ----------------------------------------------------------------
# 2. 네트워크 모듈 (VPC, Subnets, IGW, NAT, Route Tables)
# ----------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.3" # 모듈 버전 지정

  name = "quiz-vpc" # VPC 이름
  cidr = "172.16.0.0/16" # VPC 대역

  azs             = ["${var.region}a"] # 다이어그램에 따라 1개의 AZ만 사용
  public_subnets  = ["172.16.1.0/24"] # 퍼블릭 서브넷 대역
  private_subnets = ["172.16.2.0/24"] # 프라이빗 서브넷 대역

  # Private Subnet에서 외부(인터넷)로 통신(예: yum update)이 가능하도록 NAT Gateway 구성
  enable_nat_gateway = true
  single_nat_gateway = true
  
  tags = {
    Name = "quiz-vpc"
  }
}

# ----------------------------------------------------------------
# 3. 보안 그룹(Security Groups) 모듈
# ----------------------------------------------------------------

# 3-1. Web Server용 보안 그룹 (web-sg)
module "web_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  name        = "web-server-sg"
  description = "Web Server Security Group"
  vpc_id      = module.vpc.vpc_id

  # Ingress (인바운드) 규칙
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP access from anywhere"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH access (보안상 좋지 않지만, 실습을 위해 0.0.0.0/0으로 설정)"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  
  # Egress (아웃바운드) 규칙 - 모든 트래픽 허용
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

# 3-2. MariaDB Server용 보안 그룹 (db-sg)
module "db_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  name        = "db-server-sg"
  description = "MariaDB Server Security Group"
  vpc_id      = module.vpc.vpc_id

  # Ingress (인바운드) 규칙 - Web-Server(web_sg)에서 오는 3306 포트만 허용
  ingress_with_source_security_group_id = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MariaDB access from Web SG"
      # web_sg 모듈의 ID를 참조
      source_security_group_id = module.web_sg.security_group_id 
    }
  ]
  
  # Egress (아웃바운드) 규칙 - NAT Gateway를 통해 외부로 나갈 수 있도록 허용
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}


# ----------------------------------------------------------------
# 4. EC2 인스턴스 모듈
# ----------------------------------------------------------------

# 4-1. Web-Server (Public Subnet)
module "web_server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1"

  name          = "web-server"
  ami           = var.ami_id
  instance_type = "t2.micro"
  
  vpc_security_group_ids = [module.web_sg.security_group_id]
  subnet_id              = module.vpc.public_subnets[0] # Public Subnet에 배치
  associate_public_ip_address = true # 퍼블릭 IP 할당
  
  # user-data.sh 스크립트 실행하여 웹서버 자동 설치
  user_data = file("${path.module}/user-data.sh")
  
  tags = {
    Name = "web-server"
  }
}

# 4-2. MariaDB-Server (Private Subnet)
module "db_server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1"

  name          = "mariadb-server"
  ami           = var.ami_id
  instance_type = "t2.micro"
  
  vpc_security_group_ids = [module.db_sg.security_group_id]
  subnet_id              = module.vpc.private_subnets[0] # Private Subnet에 배치
  # 'associate_public_ip_address = false'가 기본값이므로 퍼블릭 IP가 할당되지 않음
  
  tags = {
    Name = "mariadb-server"
  }
}
