variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
  
}
variable "env" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev" 
}
variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "eks-cluster"
}
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {
    "CreatedBy" = "Terraform"
    "ManagedBy" = "Terraform"
  }
}
variable "public_subnets_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
  
}
variable "private_subnets_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
}
variable "availability_zones" {
  description = "List of availability zones to use for the subnets"
  type        = list(string)
  default     = ["sa-east-1a", "sa-east-1b"]
}
variable "public_subnets" {
  description = "List of public subnets"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}



