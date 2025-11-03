
# terraform apply -var "db_username=admin2" -var "db_password=mariaPassw0rd"
# terraform destroy -var "db_username=admin2" -var "db_password=mariaPassw0rd"

# PS C:\terraform\workspace\09_file_division> $env:TF_VAR_db_username = "admin"
# PS C:\terraform\workspace\09_file_division> $env:TF_VAR_db_password = "mariaPassw0rd"
# PS C:\terraform\workspace\09_file_division> terraform apply

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}
