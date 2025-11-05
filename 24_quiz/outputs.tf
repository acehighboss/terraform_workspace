output "bastion_public_ip" {
  description = "Bastion Host의 Public IP 주소 (이 IP로 SSH 접속)"
  value       = module.bastion_host.public_ip
}

output "web_server_public_ip" {
  description = "Web Server의 Public IP 주소 (웹 브라우저 확인용)"
  value       = module.web_server.public_ip
}

output "web_server_private_ip" {
  description = "Web Server의 Private IP 주소 (Bastion에서 curl 테스트용)"
  value       = module.web_server.private_ip
}
