#!/bin/bash
# Amazon Linux 2 (yum) 기준
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# 간단한 테스트용 웹페이지 생성
echo "<html><h1>Web Server (Public Subnet)</h1><p>Terraform 모듈 실습 성공!</p></html>" > /var/www/html/index.html
