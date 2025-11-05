# ----------------------------------------------------------------
# 4. EC2 인스턴스 모듈
# ----------------------------------------------------------------

# 4-1. Bastion Host (Public Subnet)
module "bastion_host" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1"

  name = "bastion-host"
  ami  = var.ami_id
  
  instance_type          = var.instance_type
  key_name               = var.key_name # SSH 접속용 키 페어 이름
  vpc_security_group_ids = [module.bastion_sg.security_group_id]
  subnet_id              = module.vpc.public_subnets[0] # Public Subnet에 생성
  # associate_public_ip_address = true (VPC 모듈의 map_public_ip_on_launch=true로 자동 설정됨)

  tags = {
    Name = "bastion-host"
  }
}

# 4-2. Web-Server (Public Subnet)
module "web_server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1"

  name = "web-server"
  ami  = var.ami_id

  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [module.web_sg.security_group_id]
  subnet_id              = module.vpc.public_subnets[0] # Public Subnet에 생성
  
  # user-data 스크립트를 실행하여 부팅 시 Apache 웹서버 자동 설치
  user_data = file("${path.module}/user-data-web.sh")

  tags = {
    Name = "web-server"
  }
}

# 4-3. App-Server (Private Subnet)
module "app_server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1"

  name = "app-server"
  ami  = var.ami_id

  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [module.app_sg.security_group_id]
  subnet_id              = module.vpc.private_subnets[0] # Private Subnet (App-Tier)
  
  # associate_public_ip_address = false (VPC 모듈의 기본값)

  tags = {
    Name = "app-server"
  }
}

# 4-4. MariaDB-Server (Private Subnet)
module "db_server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1"

  name = "mariadb-server"
  ami  = var.ami_id
  
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [module.db_sg.security_group_id]
  subnet_id              = module.vpc.private_subnets[1] # Private Subnet (DB-Tier)

  tags = {
    Name = "mariadb-server"
  }
}
