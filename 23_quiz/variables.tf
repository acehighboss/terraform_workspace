variable "region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2" # 서울 리전
}

variable "ami_id" {
  description = "EC2 인스턴스용 AMI ID (Amazon Linux 2)"
  type        = string
  # AMI ID는 리전마다 다릅니다. 이 ID는 ap-northeast-2 (서울)의 Amazon Linux 2 (x86)입니다.
  default     = "ami-0c76ab616fd4e97b8" 
}
