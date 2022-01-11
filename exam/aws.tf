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
  region  = var.region
}

variable "region" {
  type    = string
  default = "us-west-2"
}

variable "key_pair" {
  type    = string
  default = "aws_main"
}

variable "image_id" {
  type    = string
  default = "ami-0c7ea5497c02abcaf" # Debian 10
}

variable "subnet_id" {
  type    = string
  default = "subnet-028cdc74e61702420"
}

variable "av_zone" {
  type    = string
  default = "us-west-2a"
}

variable "vpc_id" {
  type    = string
  default = "vpc-021ca6cda34354a3a"
}

output "instance_dns" {
  value = aws_instance.applications.public_dns
}

resource "aws_instance" "applications" {
  ami                    = var.image_id
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.allow_app_traffic.id}"]
  subnet_id              = var.subnet_id
  availability_zone      = var.av_zone
  key_name               = var.key_pair
  tags                   = {}
  user_data              = <<EOF
#!/bin/bash
sudo apt update && sudo apt install -y nginx subversion docker.io

svn cat https://github.com/NereySer/Andersen-devops/trunk/exam/nginx/default > /etc/nginx/sites-available/default
svn cat https://github.com/NereySer/Andersen-devops/trunk/exam/nginx/index.nginx-debian.html > /var/www/html/index.nginx-debian.html
sudo service nginx restart

svn cat https://github.com/NereySer/Andersen-devops/trunk/exam/init_apps > ./init_apps
chmod +x init_apps
sudo -u admin ./init_apps app1
sudo -u admin ./init_apps app2
rm init_apps

EOF
}

resource "aws_security_group" "allow_app_traffic" {
  name   = "allow_traffic"
  vpc_id = var.vpc_id
  tags   = {}

  ingress {
    description = "app from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

