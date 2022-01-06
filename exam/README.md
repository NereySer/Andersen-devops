# Terraform file usage
Requires the awscli with configured credentials. Avalible variables:
* key_pair - key pair to grant SSH access. Optional, default is "aws_main"
* region - region to create VM. Default is "us-west-2".
* image_id - id of image to create VM. Default is "ami-0c7ea5497c02abcaf" (Debian 10).
* vpc_id - id of the VPC to create VM. Default is "vpc-021ca6cda34354a3a".
* subnet_id - subnets id to create VM. Default is "subnet-028cdc74e61702420".
* av_zone - availability zones to create VM. Default is "us-west-2a".

# Behavior
Creates EC2 instance, downloads the rebuild scripts from this repository and runs them. Rebuild scripts are made to download or update source files and Dockerfile, then to build an image and to start new container for each application. After that the scripts purify unnecessary data.
