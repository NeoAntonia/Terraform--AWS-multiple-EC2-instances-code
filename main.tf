terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "eu-west-2"
}

resource "aws_key_pair" "my-pub-key" {
  key_name   = "my-pub-key"
  public_key = file("${var.key_path}")
}

resource "aws_instance" "app_server" {

 count = length(var.server_names)
  ami           = "ami-028ea3af39a4a7661"
  instance_type = var.instance_types[count.index]
  key_name = aws_key_pair.my-pub-key.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  associate_public_ip_address = true
 
  provisioner "local-exec" {
    command = "sudo hostnamectl set-hostname ${var.server_names[count.index]}"
  }
   user_data = "${file("init.sh")}"
  tags = {
    Name = var.server_names[count.index]
  }
}
