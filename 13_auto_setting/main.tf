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

# 웹 서버 구성 후 AMI 만들기
# 목표: 오토 스케일 그룹에 최신 웹 서버의 이미지로 만들기
# 구성 대상 및 방법:
# aws_ami_from_instance(인스턴스로 AMI 이미지 만들기)
# 웹 서버를 대상으로 이미지 만들기
# 웹 서버 안에 쉘 스크립트 동작보다 빠르게 이미지를 생성한다면 depends_on = [ null_resource.quiz_web_ec2_time_wait ] 설정

# null_resource(운영체제 명령어 실행)
# 웹 서버 안에 쉘 스크립트 동작보다 빠르게 이미지를 생성한다면 "until curl 웹서버; do" 설정

# 확인:
# 로드 밸런스의 DNS 주소로 웹 서버 접근
# AWS 웹 콘솔 -> ASG에서 생성 확인

# 제출 자료:
# 로드 밸런스의 DNS 주소로 웹 서버 접근
# 13_auto_setting(terraform code)

# 제출 기간: 2025년 10월 27일 15시까지