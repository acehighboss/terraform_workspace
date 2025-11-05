variable "region" {
  description = "AWS 리전 (다이어그램 기준)"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "EC2 인스턴스용 AMI ID (us-east-1의 Amazon Linux 2)"
  type        = string
  default     = "ami-0a3c3a20c09d6f377" # us-east-1, Amazon Linux 2 (x86)
}

variable "key_name" {
  description = "EC2 인스턴스 접속용 SSH 키 페어 이름 (!!반드시 본인의 키 이름으로 수정!!)"
  type        = string
  default     = "my-key-pair" # <--- 본인의 AWS 키 페어 이름으로 변경하세요
}
