output "public_route_table_id" {
  value       = aws_route_table.public_route_table.id
  description = "ID de la tabla de rutas pública"
}

output "public_subnet_1" {
  value       = aws_subnet.public_subnet_1.id
  description = "ID de la primera subnet pública"
}
output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "ID de la VPC creada"
}






