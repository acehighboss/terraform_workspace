output "web_server_public_ip" {
  description = "Web Server의 Public IP 주소"
  value       = module.web_server.public_ip
}

output "web_server_public_dns" {
  description = "Web Server의 Public DNS 주소"
  value       = module.web_server.public_dns
}
