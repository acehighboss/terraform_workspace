variable "env" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "db_username" {
  type = string
}
variable "db_password" {
  type = string
}
variable "public_subnet_ids" {
  type = map(string)
}
variable "private_subnet_ids" {
  type = map(string)
}