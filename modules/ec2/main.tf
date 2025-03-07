provider "aws" {
  region = var.region  # Change to your desired region
}



resource "aws_instance" "web" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = var.subnet_id
  security_groups = var.security_group_id
  iam_instance_profile = var.iam_instance_profile
  key_name        = "test_US"
  # vpc_security_group_ids = var.security_group_id
  tags = {
    Name = var.instance_name
  }

  #   user_data = <<-EOT
  #   #!/bin/bash
  #   cd /tmp
  #   sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
  #   sudo systemctl enable amazon-ssm-agent
  #   sudo systemctl start amazon-ssm-agent
  # EOT
}



output "instance_id" {
  value = aws_instance.web.id
}

output "private_ip" {
  value = aws_instance.web.private_ip
}