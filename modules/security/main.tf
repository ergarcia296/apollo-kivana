# Grupo de seguridad para la aplicacion MEAN
resource "aws_security_group" "apollo_sg" {
  name        = "apollo_sg"
  description = "Grupo de seguridad para la instancia EC2"
  vpc_id      = var.vpc_id

  ingress {
    description = "Permitir trafico HTTP"
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidr_blocks
  }


  ingress {
    description = "Permitir acceso SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidr_blocks
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
