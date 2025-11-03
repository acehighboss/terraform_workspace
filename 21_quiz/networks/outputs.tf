
output "vpc_id" {
  value = aws_vpc.quiz_vpc.id
}

locals {
  public_subnet_ids = {
    for key, subnet in aws_subnet.quiz_public_subnets : 
    key => subnet.id 
  }
    private_subnet_ids = {
    for key, subnet in aws_subnet.quiz_private_subnets : 
    key => subnet.id 
  }
}

output "public_subnet_ids" {
  value = local.public_subnet_ids
}
output "private_subnet_ids" {
  value = local.private_subnet_ids
}