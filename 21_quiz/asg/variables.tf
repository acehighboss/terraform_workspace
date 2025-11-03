variable "ami_id" {
  description = "The ID of the AMI to use for the launch template"
  type        = string
}

variable "web_sg_id" {
  description = "The ID of the web security group"
  type        = string
}

variable "lb_target_group_arn" {
  description = "ARN of the LB target group"
  type        = string
}

variable "private_subnet_ids" {
  description = "Map of private subnet IDs"
  type        = map(string)
}

variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}