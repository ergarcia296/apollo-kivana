output "web_server_security_group_id" {
  value       = aws_security_group.apollo_sg.id
  description = "ID del grupo de seguridad para los servidores web"
}


