variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "eks-cluster"
  
}
variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.31"
  
}
variable "private_subnet_ids" {
  description = "List of private subnet IDs for the EKS cluster"
  type        = list(string)
  default     = []
}
variable "public_subnet_ids" {
  description = "List of public subnet IDs for the EKS cluster"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID for the EKS cluster"
  type        = string
  default     = ""
}
variable "endpoint_private_access" {
  description = "Enable private endpoint access for the EKS cluster"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public endpoint access for the EKS cluster"
  type        = bool
  default     = true
  
}

variable "public_access_cidrs" {
  description = "CIDRs allowed to access the EKS cluster public endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
  
}
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {
    "CreatedBy" = "Terraform"
    "ManagedBy" = "Terraform"
  }
  
}

variable "cluster_log_types" {
  description = "List of EKS cluster log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  
}

variable "env" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
  
}


variable "node_groups" {
  description = "Map of EKS node groups with their configurations"
  type        = map(object({
    desired_size = number
    max_size     = number
    min_size     = number
    instance_types = list(string)
    capacity_type  = string
    disk_size      = number
    max_unavailable = optional(number, 1)
  }))
  default     = {}
  
}
variable "ec2_ssh_key" {
  description = "EC2 SSH key pair name for EKS worker nodes"
  type        = string
  default     = ""
  
}



