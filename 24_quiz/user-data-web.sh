#!/bin/bash
# Amazon Linux 2 (yum) 기준
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# 간단한 테스트용 웹페이지 생성
echo "<html><h1>Web Server (Web-Tier)</h1><p>3-Tier Module Quiz Success!</p></html>" > /var/www/html/index.html
