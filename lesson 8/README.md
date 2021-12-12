# Terraform file usage
Requires the awscli with configured credentials. Avalible variables:
* AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY - credentials to grant access to S3 bucket. Required.
* region - region to create VMs. Default is us-west-2
* image_id - id of image to create VMs. Default is ami-0c7ea5497c02abcaf (Debian 10)
* vpc_id - id of the VPC to create VMs. Default is vpc-021ca6cda34354a3a
* av_zones and subnets_id - lists of the same size providing availability zones and corresponding subnets id

# TIL
I was shown the basic usage of AWS services and sample of usage of Terraform

_10.12.2021_
