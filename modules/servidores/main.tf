# Terraform Data Block - To Lookup Latest Ubuntu 20.04 AMI Image


data "aws_ami" "apollo" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ami-apollo"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["self"]
}


# Elastic Network Interfaces (ENI) para Web Servers
resource "aws_network_interface" "web_server_eni_1" {
  count           = var.web_server_count
  subnet_id       = var.web_server_subnet_id_1
  private_ips     = [var.webserver_1_private_ip] # Asigna una IP única a cada ENI
  security_groups = [var.security_group_ids]


  tags = {
    Name = "Web-Server-ENI-1"
  }
}




resource "aws_eip" "web_server_eip_1" {
  count             = var.web_server_count
  network_interface = aws_network_interface.web_server_eni_1[count.index].id

  tags = {
    Name = "Web-Server-EIP-${count.index + 1}"
  }
}





# Terraform Resource Block - To Build EC2 instance in Public Subnet
resource "aws_instance" "web_server_1" {
  ami           = data.aws_ami.apollo.id
  instance_type = "t3.medium"
  key_name      = var.key_name

  network_interface {
    network_interface_id = aws_network_interface.web_server_eni_1[0].id
    device_index         = 0

  }
  user_data = <<-EOF
    #!/bin/bash
    cd /home/ubuntu/graphql-server-example && sudo npm start
    EOF

  tags = {
    Name = "apollo"
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = var.ssh_private_key
    host        = aws_eip.web_server_eip_1[count.index].public_ip
  }

}







