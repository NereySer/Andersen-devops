terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = var.region
}

provider "github" {
  token = var.GIT_ACCESS_TOKEN
}

variable "GIT_ACCESS_TOKEN" {
  type    = string
  default = ""
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
sudo apt update && sudo apt install -y nginx subversion docker.io apache2 php libapache2-mod-php

sudo service nginx stop
sudo service apache2 stop

svn cat https://github.com/NereySer/Andersen-devops/trunk/exam/system/sudoers > /etc/sudoers.d/www-data

rm /var/www/html/*

svn cat https://github.com/NereySer/Andersen-devops/trunk/exam/nginx/default > /etc/nginx/sites-available/default
svn cat https://github.com/NereySer/Andersen-devops/trunk/exam/nginx/index.nginx-debian.html > /var/www/html/index.nginx-debian.html

svn cat https://github.com/NereySer/Andersen-devops/trunk/exam/apache/ports.conf > /etc/apache2/ports.conf
svn cat https://github.com/NereySer/Andersen-devops/trunk/exam/apache/000-default.conf > /etc/apache2/sites-available/000-default.conf
svn cat https://github.com/NereySer/Andersen-devops/trunk/exam/apache/rebuild.php > /var/www/html/rebuild.php

sudo service nginx restart
sudo service apache2 restart

cd /bin
svn cat https://github.com/NereySer/Andersen-devops/trunk/exam/system/init_app > ./init_app
chmod +x init_app
sudo -u admin ./init_app app1
sudo -u admin ./init_app app2
rm init_apps

cd /home/admin
svn cat https://github.com/NereySer/Andersen-devops/trunk/exam/system/rebuild_app > ./rebuild_app
chmod +x rebuild_app

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

resource "github_repository_webhook" "foo" {
  count = var.GIT_ACCESS_TOKEN == "" ? 0 : 1

  repository = "Andersen-devops"

  configuration {
    url          = format("http://%s/rebuild.php", aws_instance.applications.public_dns)
    content_type = "form"
    insecure_ssl = false
  }

  active = true

  events = ["push"]
}

