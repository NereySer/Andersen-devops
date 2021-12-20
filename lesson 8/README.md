# Terraform file usage
Requires the awscli with configured credentials. Avalible variables:
* AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY - credentials to grant access to S3 bucket. Required.
* region - region to create VMs. Default is us-west-2.
* image_id - id of image to create VMs. Default is ami-0c7ea5497c02abcaf (Debian 10).
* vpc_id - id of the VPC to create VMs. Default is vpc-021ca6cda34354a3a. If is set to "", a new VPC, internet gate and public route is created. Also creation of the subnets is forced, subnets_id in that case ignored. cidr_block of the new VPC is 172.31.0.0/16.
* subnets_id - list of the subnets id. If is set to \[\], a new subnets is created. Default is \["subnet-028cdc74e61702420", "subnet-036d8d2dcbcadf3d1"\].
* subn_cidr_blocks - cidr blocks of the new creted subnets. Ignored if no creation is used. Default is \["172.31.64.0/20", "172.31.80.0/20"\].
* av_zones - list of the corresponding availability zones. Must be the same size as subnets_id (or subn_cidr_blocks if subnet creation is used). Default is \["us-west-2a", "us-west-2b"\].

# TIL
I was shown the basic usage of AWS services and the sample of usage of Terraform

_10.12.2021_
