# ----------------------------------------------------------------
# 3. 보안 그룹(Security Groups) 모듈
# ----------------------------------------------------------------

# 3-1. Bastion Host용 보안 그룹 (bastion-sg)
module "bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  name        = "bastion-sg"
  description = "Security Group for Bastion Host"
  vpc_id      = module.vpc.vpc_id

  # Ingress (인바운드): 내 PC에서 SSH(22) 트래픽만 허용
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH from anywhere"
      cidr_blocks = "0.0.0.0/0" # 보안상 MyIP를 쓰는 것이 좋으나 실습 편의상 0.0.0.0/0
    }
  ]

  # Egress (아웃바운드): 모든 트래픽 허용
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

# 3-2. Web Server용 보안 그룹 (web-sg)
module "web_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  name        = "web-sg"
  description = "Security Group for Web Tier"
  vpc_id      = module.vpc.vpc_id

  # Ingress (인바운드):
  # 1. 인터넷에서 HTTP(80) 허용
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP from anywhere"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  # 2. Bastion Host(bastion-sg)에서 SSH(22) 허용
  ingress_with_source_security_group_id = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH from Bastion SG"
      source_security_group_id = module.bastion_sg.security_group_id
    }
  ]

  # Egress (아웃바운드): 모든 트래픽 허용
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

# 3-3. App Server용 보안 그룹 (app-sg)
module "app_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  name        = "app-sg"
  description = "Security Group for App Tier"
  vpc_id      = module.vpc.vpc_id

  # Ingress (인바운드):
  # 1. Web-Server(web-sg)에서 App Port(8080) 허용
  # 2. Bastion Host(bastion-sg)에서 SSH(22) 허용
  ingress_with_source_security_group_id = [
    {
      from_port   = 8080 # App Port (예: Tomcat)
      to_port     = 8080
      protocol    = "tcp"
      description = "App access from Web SG"
      source_security_group_id = module.web_sg.security_group_id
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH from Bastion SG"
      source_security_group_id = module.bastion_sg.security_group_id
    }
  ]

  # Egress (아웃바운드): 모든 트래픽 허용 (NAT Gateway를 통해 외부 통신)
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

# 3-4. DB Server용 보안 그룹 (db-sg)
module "db_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  name        = "db-sg"
  description = "Security Group for DB Tier"
  vpc_id      = module.vpc.vpc_id

  # Ingress (인바운드):
  # 1. App-Server(app-sg)에서 MariaDB(3306) 허용
  # 2. Bastion Host(bastion-sg)에서 SSH(22) 허용
  ingress_with_source_security_group_id = [
    {
      from_port   = 3306 # MariaDB Port
      to_port     = 3306
      protocol    = "tcp"
      description = "DB access from App SG"
      source_security_group_id = module.app_sg.security_group_id
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH from Bastion SG"
      source_security_group_id = module.bastion_sg.security_group_id
    }
  ]

  # Egress (아웃바운드): 모든 트래픽 허용 (NAT Gateway를 통해 외부 통신)
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}
