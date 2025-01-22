output "subnet_a_id" {
  value = aws_subnet.subnet-a.id
}

output "subnet_b_id" {
  value = aws_subnet.subnet-b.id
}

output "security_group_id" {
    value = aws_security_group.ec2_sg.id
  
}
