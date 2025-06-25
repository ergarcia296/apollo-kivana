# Crea llave RSA 
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
# Crea key pair en AWS 
resource "aws_key_pair" "llave_rsa" {
  key_name   = var.name
  public_key = tls_private_key.ssh_key.public_key_openssh
}
# Guardar la llave localmente
resource "local_file" "llave_privada" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${path.module}/id_rsa"
}
resource "null_resource" "permiso_llave" {
  depends_on = [local_file.llave_privada]
  provisioner "local-exec" {
    command = "chmod 600 ${path.module}/id_rsa"
  }
}
