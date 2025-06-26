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

variable "kibana_ingress_cidr_blocks" {
  description = "Lista de CIDR blocks permitidos para acceder a Kibana (puerto 5601)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
