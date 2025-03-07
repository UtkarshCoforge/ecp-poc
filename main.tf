provider "aws" {
  region = var.region  # Change to your desired region
}

module "vpc" {
  source          = "./modules/vpc"
  cidr_block      = "10.0.0.0/16"
  vpc_name        = "my-vpc"
  subnet_a_cidr   = "10.0.1.0/24"
  subnet_b_cidr   = "10.0.2.0/24"
  az_a            = "us-east-1a"
}

module "iam" {
  source          = "./modules/iam"
  role_name       = "EC2SSMRole"
}

data "aws_ami" "linux-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    # values = ["amzn2-ami-amd-hvm-2.0.20230727.0-x86_64-gp2"]
    values = ["amzn2-ami-hvm*"]

  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


module "ec2" {
  source               = "./modules/ec2"
  ami_id               = data.aws_ami.linux-ami.id  # Replace with a valid AMI ID
  instance_type        = "t2.micro"
  security_group_id    = [module.vpc.security_group_id]
  subnet_id            = module.vpc.subnet_a_id
  iam_instance_profile = module.iam.ec2_instance_profile
  instance_name        = "my-ec2-ssm-instance"
}

# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "terraform-state-bucket"
# }

# data "aws_iam_policy_document" "backend" {
#   statement {
#     principals {
#       type        = "AWS"
#       identifiers = ["442426854264"]
#     }

#     actions = [
#       "s3:GetObject",
#       "s3:ListBucket",
#     ]

#     resources = [
#       "arn:aws:s3:::terraform_state/backend/state",
#       "arn:aws:s3:::terraform_state/backend/state",
#     ]
#   }
# }

# resource "aws_s3_bucket_policy" "backend" {
#   bucket = aws_s3_bucket.terraform_state.id
#   policy = data.aws_iam_policy_document.backend.json
# }


# resource "aws_dynamodb_table" "terraform_lock" {
#   name         = "terraform-lock-table"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }


terraform {
  backend "s3" {
    bucket         = "tfstate-89"
    key            = "tfstateFile"
    region         = "us-east-1"
    # dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}

