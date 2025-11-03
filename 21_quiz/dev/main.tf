terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-2"
  profile = "terraform-user"
}

locals {
  env = "dev"
}

module "networks" {
  source         = "../networks"
  vpc_cidr_block = "192.168.0.0/16"
  env            = local.env
}

module "instances" {
  source             = "../instances"
  env                = local.env
  db_password        = var.db_password
  db_username        = var.db_username
  private_subnet_ids = module.networks.private_subnet_ids
  public_subnet_ids  = module.networks.public_subnet_ids
  vpc_id             = module.networks.vpc_id
}

# [추가] ELB 모듈 호출
module "elb" {
  source            = "../elb"
  env               = local.env
  vpc_id            = module.networks.vpc_id
  public_subnet_ids = module.networks.public_subnet_ids
}

# [추가] ASG 모듈 호출
module "asg" {
  source                = "../asg"
  env                   = local.env
  ami_id                = module.instances.ami_id                 # instances 모듈 출력
  web_sg_id             = module.instances.web_sg_id              # instances 모듈 출력
  lb_target_group_arn   = module.elb.lb_target_group_arn        # elb 모듈 출력
  private_subnet_ids    = module.networks.private_subnet_ids      # networks 모듈 출력
}

# PS C:\terraform\workspace\20_quiz\stage> cd ..\..\21_quiz\dev\
# PS C:\terraform\workspace\21_quiz\dev> terraform fmt
# main.tf
# PS C:\terraform\workspace\21_quiz\dev> terraform init
