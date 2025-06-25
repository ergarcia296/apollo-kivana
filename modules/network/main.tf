#Define the VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

#Trae informacion de las zonas de disponibilidad en la region actual
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

#Despliega una subnet publica en cada zona de disponibilidad
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true


}
resource "aws_internet_gateway" "custom_igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "CustomIGW"
  }
}
#Crea la tabla de rutas para la subnet publica
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.custom_igw.id
  }
  tags = {
    Name = "PublicRouteTable"
  }

}
#Asocia la tabla de rutas a la subnet publica
resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

