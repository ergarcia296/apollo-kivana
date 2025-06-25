output "ami_id" {
  value       = data.aws_ami.latest_ami.id
  description = "ID de la última AMI creada por Packer"
}

output "ami_name" {
  value       = data.aws_ami.latest_ami.name
  description = "Nombre de la última AMI creada por Packer"
}
