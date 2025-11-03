# S3 버킷(bucket) 생성
# S3로 boot.war 파일(object)을 업로드

# 웹서버가 S3에 업로드된 boot.war를 다운로드
#  - IAM Role, IAM policy(S3에 다운로드권한) 생성
#  - 웹서버가 위에서 생성한 IAM Role 설정

# boot.war 다운로드  후
# aws s3 cp s://버킷이름/오브젝트이름 "웹서버의 다운로드 받을 경로"
# boot.war를 /opt/tomcat/tomcat-10/webapps/boot.war 위치로 move한다.
# sed -i 's/^spring.datasource.username.*/spring.datasource.username=web/' /opt/tomcat/tomcat-10/webapps/boot/WEB-INF/classes/application.properties
# sed -i 's/^spring.datasource.password.*/spring.datasource.password=1234/' /opt/tomcat/tomcat-10/webapps/boot/WEB-INF/classes/application.properties
# sed -i 's/^spring.datasource.url.*/spring.datasource.url=jdbc:mariadb://DB_EC2_PRIVATE_IP:3306/care /' /opt/tomcat/tomcat-10/webapps/boot/WEB-INF/classes/application.properties


resource "aws_s3_bucket" "quiz_s3_bucket" {
  bucket = "quiz-kyes-bucket"

  tags = {
    Name = "quiz-kyes-bucket"
  }
}

resource "aws_s3_object" "quiz_s3_object" {
  bucket = aws_s3_bucket.quiz_s3_bucket.id
  key    = "boot.war"
  source = "${path.module}/boot.war"
  etag   = filemd5("boot.war")
}

resource "aws_iam_role" "quiz_s3_ec2_role" {
  name = "quiz-s3-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    "Name" = "quiz-s3-ec2-role"
  }
}

resource "aws_iam_role_policy" "quiz_s3_ec2_policy" {
  name = "quiz-s3-ec2-policy"
  role = aws_iam_role.quiz_s3_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
        ]
        Effect = "Allow"
        # Resource = "*"
        Resource = "arn:aws:s3:::quiz-kyes-bucket/*"
      },
    ]
  })
}

resource "aws_iam_instance_profile" "quiz_instance_profile" {
  name = "quiz-instance-profile"
  role = aws_iam_role.quiz_s3_ec2_role.name
}