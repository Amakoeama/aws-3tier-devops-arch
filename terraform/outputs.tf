#--- ALB DNS (main output) ---
# To access the application on the browser
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.app_alb.dns_name
}

#--- EC2 Public IP (for SSH testing, for demo purposes only. In production, expose EC2 through ALB.)
output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

#--- EC2 Private IP (for debugging, RDS, and private networks) ---
output "ec2_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.app_server.private_ip
}

#--- VPC ID (For debugging or testing) --- 
output "vpc_id" {
  description = "ID of the main VPC"
  value       = aws_vpc.main.id
}
