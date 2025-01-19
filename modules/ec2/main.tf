provider "aws" {
  region = var.region  # Change to your desired region
}



# Create a Security Group
resource "aws_security_group" "ec2_sg" {
  name_prefix = "ec2-sg-"
  vpc_id      = aws_vpc.main.vpc_id


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # No inbound access allowed
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }
   depends_on = [aws_instance.web]
}

resource "aws_instance" "web" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = var.subnet_id
  iam_instance_profile = var.iam_instance_profile
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  tags = {
    Name = var.instance_name
  }

    user_data = <<-EOT
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y amazon-ssm-agent
    sudo systemctl enable amazon-ssm-agent
    sudo systemctl start amazon-ssm-agent
  EOT
}



output "instance_id" {
  value = aws_instance.web.id
}

output "private_ip" {
  value = aws_instance.web.private_ip
}