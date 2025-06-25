output "web_server_ids" {
  value       = [aws_instance.web_server_1.id]
  description = "IDs de los servidores web"
}


output "ip_publica_webserver_1" {
  value       = aws_instance.web_server_1.public_ip
  description = "IP pública del primer servidor web"
}

output "ip_privada_webserver_1" {
  value       = aws_instance.web_server_1.private_ip
  description = "IP privada del primer servidor web"
}

