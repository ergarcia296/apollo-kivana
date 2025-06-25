variable "vpc_id" {
  type = string
}


variable "web_server" {
  type = string
}

variable "ingress_cidr_blocks" {
  description = "CIDR blocks permitidos para tráfico de ingreso"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
