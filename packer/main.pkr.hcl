packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }

  }
}
source "amazon-ebs" "ubuntu" {
  ami_name      = "ami-apollo"
  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}
# AMI para Apollo Server
build {
  name = "ubuntu"
  sources = [
    "source.amazon-ebs.ubuntu",
  ]
  provisioner "file" {
    source      = "./packer/files/"
    destination = "/tmp"
  }
  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "cd ~",
      "curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh",
      "sudo bash nodesource_setup.sh",
      "sudo echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections",
      "sudo apt-get install nodejs -y",
      "sudo echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections",
      "sudo apt-get install build-essential -y",
      "sudo mkdir /home/ubuntu/graphql-server-example",
      "sudo npm init --yes && sudo npm pkg set type=\"module\"",
      "sudo npm install -y @apollo/server graphql",
      "sudo mkdir /home/ubuntu/graphql-server-example/src",
      "sudo touch /home/ubuntu/graphql-server-example/src/index.ts",
      "sudo npm install --save-dev typescript @types/node",
      "sudo cp /tmp/tsconfig.json /home/ubuntu/graphql-server-example/tsconfig.json",
      "sudo cp /tmp/package.json /home/ubuntu/graphql-server-example/package.json",
      "sudo cp /tmp/index.ts /home/ubuntu/graphql-server-example/src/index.ts",
    ]
  }
  post-processor "shell-local" {
    inline = [
      "AMI_ID=$(aws ec2 describe-images --filters 'Name=name,Values=ami-apollo' --query 'Images[0].ImageId' --output text --region 'us-east-1')"
    ]
  }
}

