#--- Ec2 instance ---

# --- Lookup latest Amazon Linux 2 AMI ---
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Amazon official
}


resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = var.key_name

  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name

  user_data = templatefile("${path.module}/../scripts/ec2-bootstrap.sh", {
    db_host     = aws_db_instance.postgres.address
    db_name     = "postgres"
    db_user     = "masteruser"
    db_password = var.db_password
  })


  tags = {
    Name        = "3tier-app-server"
    Environment = var.environment
    Role        = "app-server"
  }

}


