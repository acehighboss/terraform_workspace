variable "vpc_cidr_block" {
  type = string
}

variable "env" {
  type = string
}

variable "public_subnets" {
  default = {
    public-subnet-10 = 10
    public-subnet-30 = 30
  }
}

variable "private_subnets" {
  default = {
    private-subnet-11 = 11
    private-subnet-31 = 31
    private-subnet-12 = 12
    private-subnet-32 = 32
  }
}