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

# PS C:\terraform\workspace\20_quiz\stage> cd ..\..\21_quiz\dev\
# PS C:\terraform\workspace\21_quiz\dev> terraform fmt
# main.tf
# PS C:\terraform\workspace\21_quiz\dev> terraform init
