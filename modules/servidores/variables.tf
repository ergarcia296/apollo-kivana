variable "ami_name" {

}
variable "public_subnet_1" {
  type = string
}
variable "ssh_private_key" {
  description = "Clave privada SSH generada"
  type        = string

}
# Web Servers
variable "web_server_count" {
  description = "Número de instancias de servidores web"
  type        = number
  default     = 1
}
variable "web_server_subnet_id_1" {
  description = "ID de la subnet para los servidores web"
  type        = string
}



variable "web_server_private_ip_base" {
  description = "IPs privadas de los servidores web"
  type        = string
}

variable "security_group_ids" {
  description = "ID del grupo de seguridad para los servidores web"
  type        = string
}


variable "webserver_1_private_ip" {
  description = "IP privada de webserver 1"
  type        = string
}

variable "key_name" {
  description = "Nombre del par de claves SSH en AWS"
  type        = string
}










