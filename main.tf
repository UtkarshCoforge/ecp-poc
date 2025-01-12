provider "aws" {
  region = var.region  # Change to your desired region
}

module "vpc" {
  source          = "./modules/vpc"
  cidr_block      = "10.0.0.0/16"
  vpc_name        = "my-vpc"
  subnet_a_cidr   = "10.0.1.0/24"
  az_a            = "us-east-1a"
}

module "iam" {
  source          = "./modules/iam"
  role_name       = "EC2SSMRole"
}

data "aws_ami" "linux-ami" {
  filter {
    name   = "name"
    values = ["amzn2-ami-amd-hvm-2.0.20230727.0-x86_64-gp2"]
    #values = ["Windows_Server-2019-English-Full-Base-2023*"] // for linux "amzn2-ami-amd-hvm-2.0.20230727.0-x86_64-gp2"
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  most_recent = true
  owners      = ["amazon"]
}


module "ec2" {
  source               = "./modules/ec2"
  ami_id               = data.aws_ami.linux-ami.id  # Replace with a valid AMI ID
  instance_type        = "t2.micro"
  subnet_id            = module.vpc.subnet_a_id
  iam_instance_profile = module.iam.ec2_instance_profile
  instance_name        = "my-ec2-ssm-instance"
}