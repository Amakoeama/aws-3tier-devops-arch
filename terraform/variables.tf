variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

#--- Public subnet ---
variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

#--- Pivate subnet ---
variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

#--- Availabiliy zones ---
variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

#--- Ec2 type ---
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

#--- SSH key pair ---
variable "key_name" {
  description = "Existing AWS key pair name"
  type        = string
  default     = "rhel-lab-key"
}

variable "environment" {
  type    = string
  default = "dev"
}

#--- DB Password --- 
variable "db_password" {
  description = "Master password for the RDS PostgreSQL instance"
  type        = string
}


