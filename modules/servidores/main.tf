# Terraform Data Block - To Lookup Latest Ubuntu 20.04 AMI Image


data "aws_ami" "apollo" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ami-apollo-*"]
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
    # Actualizar e instalar dependencias
    apt-get update
    apt-get install -y wget gnupg apt-transport-https openjdk-11-jdk curl

    # Agregar repo de Elastic 7.x
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
    echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" > /etc/apt/sources.list.d/elastic-7.x.list

    apt-get update
    apt-get install -y elasticsearch=7.17.18 kibana=7.17.18 apm-server=7.17.18

    # Configurar Elasticsearch
    echo "network.host: 0.0.0.0" >> /etc/elasticsearch/elasticsearch.yml
    echo "discovery.type: single-node" >> /etc/elasticsearch/elasticsearch.yml

    # Configurar Kibana
    echo "server.host: \"0.0.0.0\"" >> /etc/kibana/kibana.yml

    # Configurar APM Server
    cat <<EOL2 >> /etc/apm-server/apm-server.yml
    apm-server:
      host: "0.0.0.0:8200"

    output.elasticsearch:
      hosts: ["http://localhost:9200"]

    setup.kibana:
      host: "http://localhost:5601"
    EOL2

    # Aumentar límite de memoria virtual requerido
    sysctl -w vm.max_map_count=262144
    echo "vm.max_map_count=262144" >> /etc/sysctl.conf

    # Habilitar e iniciar servicios
    systemctl daemon-reexec
    systemctl enable elasticsearch
    systemctl start elasticsearch

    systemctl enable kibana
    systemctl start kibana

    systemctl enable apm-server
    systemctl start apm-server

    # Asegúrate de que el directorio existe
    mkdir -p /home/ubuntu/graphql-server-example

    # Da permisos al usuario ubuntu
    chown -R ubuntu:ubuntu /home/ubuntu/graphql-server-example
    chmod -R u+rwX /home/ubuntu/graphql-server-example

    # Instala elastic-apm-node como el usuario ubuntu
    sudo -u ubuntu bash -c "cd /home/ubuntu/graphql-server-example && npm install elastic-apm-node"
    
    cat <<EOL > /etc/systemd/system/apollo.service
    [Unit]
    Description=Apollo Server
    After=network.target

    [Service]
    Type=simple
    User=ubuntu
    WorkingDirectory=/home/ubuntu/graphql-server-example
    ExecStart=/usr/bin/npm start
    Restart=always

    [Install]
    WantedBy=multi-user.target
    EOL

    chown root:root /etc/systemd/system/apollo.service
    chmod 644 /etc/systemd/system/apollo.service

    systemctl daemon-reload
    systemctl enable apollo.service
    systemctl start apollo.service
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