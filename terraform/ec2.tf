#--- Ec2 instance ---
resource "aws_instance" "app_server" {
  ami           = "ami-0c2b8ca1dad447f8a" # Amazon Linux 2023 (us-east-1)
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public[0].id
  key_name      = var.key_name

  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]

  tags = {
    Name = "3tier-app-server"
  }
}
