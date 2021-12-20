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

variable "AWS_ACCESS_KEY_ID" {
  type = string
}
variable "AWS_SECRET_ACCESS_KEY" {
  type = string
}

variable "region" {
  type    = string
  default = "us-west-2"
}

variable "image_id" {
  type    = string
  default = "ami-0c7ea5497c02abcaf" # Debian 10
}

variable "subnets_id" {
  type    = list(string)
  default = ["subnet-028cdc74e61702420", "subnet-036d8d2dcbcadf3d1"]
}

variable "av_zones" {
  type    = list(string)
  default = ["us-west-2a", "us-west-2b"]
}

variable "subn_cidr_blocks" {
  type    = list(string)
  default = ["172.31.64.0/20", "172.31.80.0/20"]
}

variable "vpc_id" {
  type    = string
  default = "vpc-021ca6cda34354a3a"
}

locals {
  create_vpc     = var.vpc_id == "" ? 1 : 0
  vpc_id         = concat(aws_vpc.test[*].id, [var.vpc_id])[0] # If VPC creation is used, statement is selects the ID of created VPC, otherwise it selects the provided VPC ID
  create_subnets = (var.vpc_id == "" || length(var.subnets_id) == 0) ? zipmap(var.av_zones, var.subn_cidr_blocks) : {}
  subnets_id     = length(local.create_subnets) == 0 ? var.subnets_id : values(aws_subnet.subnets)[*].id
}

resource "aws_vpc" "test" {
  count      = local.create_vpc
  cidr_block = "172.31.0.0/16"
}

resource "aws_internet_gateway" "gw" {
  count  = local.create_vpc
  vpc_id = local.vpc_id
}

resource "aws_route" "pub_route" {
  count                  = local.create_vpc
  route_table_id         = concat(aws_vpc.test[*].main_route_table_id, [""])[0] # In case of no creation provides dummy value 
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = concat(aws_internet_gateway.gw[*].id, [""])[0] # In case of no creation provides dummy value
}

resource "aws_subnet" "subnets" {
  for_each                = local.create_subnets
  vpc_id                  = local.vpc_id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true
}

resource "aws_instance" "applications" {
  for_each = zipmap(var.av_zones, local.subnets_id)

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
  vpc_id   = local.vpc_id
}

resource "aws_lb_target_group_attachment" "instances" {
  for_each = aws_instance.applications

  target_group_arn = aws_lb_target_group.lbtarg.arn
  target_id        = each.value.id
  port             = 80
}




resource "aws_security_group" "allow_app_traffic" {
  name   = "allow_traffic"
  vpc_id = local.vpc_id

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

resource "aws_security_group" "allow_lb_traffic" {
  name   = "allow_lb_traffic"
  vpc_id = local.vpc_id

  ingress {
    description = "app from anywhere"
    from_port   = 80
    to_port     = 80
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
  name               = "applb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.allow_lb_traffic.id}"]
  subnets            = local.subnets_id
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

