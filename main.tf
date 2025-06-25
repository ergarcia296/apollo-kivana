# Proveedor AWS
provider "aws" {
  region = "us-east-1"
}

module "network" {
  source          = "./modules/network"
  vpc_name        = "MEAN_vpc"
  vpc_cidr        = "10.0.0.0/16"
  public_subnet_1 = 1



}



module "security" {
  source     = "./modules/security"
  vpc_id     = module.network.vpc_id
  web_server = "MEAN_web_server"
}

module "llave" {
  source = "./modules/llave"
  name   = "MEAN_key"
}

module "ami" {
  source               = "./modules/ami"
  packer_template_file = "./packer/main.pkr.hcl"
  ami_name             = "ami-apollo"


}

module "servidores" {
  source                     = "./modules/servidores"
  ami_name                   = module.ami.ami_name
  depends_on                 = [module.ami, module.llave, module.network, module.security]
  public_subnet_1            = module.network.public_subnet_1
  ssh_private_key            = module.llave.ssh_private_key
  key_name                   = module.llave.name
  web_server_count           = 1
  web_server_subnet_id_1     = module.network.public_subnet_1
  web_server_private_ip_base = "10.0.0"
  webserver_1_private_ip     = "10.0.0.30"
  security_group_ids         = module.security.web_server_security_group_id


}


