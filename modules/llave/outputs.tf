output "ssh_private_key" {
  value       = tls_private_key.ssh_key.private_key_pem
  description = "Clave privada generada de acceso"

}

output "name" {
  value       = aws_key_pair.llave_rsa.key_name
  description = "Nombre de la llave SSH creada en AWS"

}
