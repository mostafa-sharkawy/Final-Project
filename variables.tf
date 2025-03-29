# variables.tf

variable "aws_region" {
  description = "AWS region"
  default     = "your-region"  # e.g., "eu-west-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "Subnet CIDR block"
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "AWS Availability Zone"
  default     = "your-region-a"  # e.g., "eu-west-1a"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  default     = "your-ami-id"  # Replace with actual AMI ID
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "your-instance-type"  # e.g., "t3.micro"
}

variable "ssh_key_name" {
  description = "AWS Key Pair Name"
  default     = "your-key-name"  # Replace with actual key pair name
}