data "aws_availability_zones" "quiz_az_names" {
  state = "available"
}

# data "aws_ami" "quiz_web_ami" {
#   filter {
#     name   = "tag:Name"
#     values = ["web-ami"]
#   }
# }