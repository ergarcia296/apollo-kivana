# Configuración de Packer


variable "packer_template_file" {
  description = "Ruta al archivo de plantilla de Packer"
  type        = string
}

# AMI
variable "ami_name" {
  description = "Nombre base de la AMI creada por Packer"
  type        = string
}



