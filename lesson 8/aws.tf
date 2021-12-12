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

variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}

variable "region" {
  default = "us-west-2"
}

variable "image_id" {
  default = "ami-0c7ea5497c02abcaf" # Debian 10
}

variable "subnets_id" {
  default = ["subnet-028cdc74e61702420", "subnet-036d8d2dcbcadf3d1"]
}

variable "av_zones" {
  default = ["us-west-2a", "us-west-2b"]
}

variable "vpc_id" {
  default = "vpc-021ca6cda34354a3a"
}

resource "aws_instance" "applications" {
  for_each = zipmap(var.av_zones, var.subnets_id)

  ami                    = var.image_id
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.allow_app_traffic.id}"]
  subnet_id              = each.value
  availability_zone      = each.key
  user_data              = <<EOF
#!/bin/bash
sudo apt update && sudo apt install -y nginx
export AWS_ACCESS_KEY_ID=${var.AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${var.AWS_SECRET_ACCESS_KEY}
export AWS_DEFAULT_REGION=${var.region}
sudo rm /var/www/html/*
aws s3 cp s3://mybucket.ru/index.html /tmp/index.html
sudo mv /tmp/index.html /var/www/html/index.html
sudo systemctl restart nginx
EOF
}






resource "aws_lb_target_group" "lbtarg" {
  name     = "lbtarg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "instances" {
  for_each = aws_instance.applications

  target_group_arn = aws_lb_target_group.lbtarg.arn
  target_id        = each.value.id
  port             = 80
}




resource "aws_security_group" "allow_app_traffic" {
  name   = "allow_traffic"
  vpc_id = var.vpc_id

  ingress {
    description = "app from anywhere"
    from_port   = 8080
    to_port     = 8080
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

resource "aws_lb" "AppLB" {
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnets_id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.AppLB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lbtarg.arn
  }
}

