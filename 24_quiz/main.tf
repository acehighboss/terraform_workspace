# 1. Terraform 및 AWS Provider 설정
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
# 'terraform-aws-modules/vpc/aws' 모듈을 사용하여 3-Tier 네트워크 환경을 구성합니다.
# 이 모듈 하나로 VPC, Public/Private Subnets, IGW, NAT Gateway, Route Tables가 모두 생성됩니다.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.3"

  name = "quiz-3-tier-vpc"
  cidr = "10.0.0.0/16" # 다이어그램의 VPC 대역

  # 다이어그램에 명시된 'us-east-1a' AZ 1개만 사용
  azs             = ["${var.region}a"]
  public_subnets  = ["10.0.1.0/24"] # Web-Tier + Bastion
  private_subnets = ["10.0.2.0/24", "10.0.3.0/24"] # App-Tier, DB-Tier

  # Private Subnet이 인터넷(예: yum update)과 통신할 수 있도록 NAT Gateway 활성화
  enable_nat_gateway = true
  single_nat_gateway = true # AZ가 1개이므로 NAT GW도 1개만 생성

  # Public Subnet의 인스턴스가 Public IP를 자동 할당받도록 설정
  map_public_ip_on_launch = true

  tags = {
    Name = "quiz-3-tier-vpc"
  }
}
