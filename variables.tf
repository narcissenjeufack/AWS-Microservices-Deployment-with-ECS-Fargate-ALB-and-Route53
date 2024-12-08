variable "aws_region" {
  description = "AWS region for deployment"
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  default     = "dev"
}

variable "alb_security_group_id" {
  description = "Security group ID for the ALB"
  default     = "sg-0example12345"
}

variable "alb_subnets" {
  description = "Subnets for the ALB"
  type        = list(string)
  default     = ["subnet-0example123", "subnet-1example456"]
}

variable "vpc_id" {
  description = "VPC ID"
  default     = "vpc-0example12345"
}

variable "desired_count" {
  description = "Number of desired ECS tasks"
  default     = 1
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID"
  default     = "Z3P5QSUBK4POTI"
}

variable "domain_name" {
  description = "Domain name for Route 53 records"
  default     = "example.com"
}

variable "prod_weight" {
  description = "Weight for the production environment"
  default     = 80
}

variable "test_weight" {
  description = "Weight for the testing environment"
  default     = 20
}
