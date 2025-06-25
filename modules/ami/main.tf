# Ejecucion de Packer
resource "null_resource" "packer_ami" {
  provisioner "local-exec" {
    command = "packer build ./packer/main.pkr.hcl"
  }
}

# Obtener la última AMI creada 
data "aws_ami" "latest_ami" {
  depends_on  = [null_resource.packer_ami]
  most_recent = true
  filter {
    name   = "name"
    values = ["${var.ami_name}*"] # Coincide con el patrón de nombre definido
  }
  owners = ["self"]
}



