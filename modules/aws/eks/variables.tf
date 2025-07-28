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


# 节点组数量和名称 (类似 EC2 配置)
variable "node_group_count" {
  description = "Number of node groups to create"
  type        = number
  default     = 0
}

variable "node_group_names" {
  description = "List of node group names"
  type        = list(string)
  default     = []
}

# 基本配置数组
variable "desired_sizes" {
  description = "List of desired sizes for each node group"
  type        = list(number)
  default     = []
}

variable "max_sizes" {
  description = "List of maximum sizes for each node group"
  type        = list(number)
  default     = []
}

variable "min_sizes" {
  description = "List of minimum sizes for each node group"
  type        = list(number)
  default     = []
}

variable "instance_types" {
  description = "List of instance types for each node group"
  type        = list(list(string))
  default     = []
}

variable "capacity_types" {
  description = "List of capacity types for each node group"
  type        = list(string)
  default     = []
}

variable "disk_sizes" {
  description = "List of disk sizes for each node group"
  type        = list(number)
  default     = []
}

variable "volume_types" {
  description = "List of volume types for each node group"
  type        = list(string)
  default     = []
}

variable "ami_types" {
  description = "List of AMI types for each node group"
  type        = list(string)
  default     = []
}

variable "key_names" {
  description = "List of key names for each node group"
  type        = list(string)
  default     = []
}

variable "max_unavailables" {
  description = "List of max unavailable for each node group"
  type        = list(number)
  default     = []
}

# 子网配置
variable "subnet_types" {
  description = "List of subnet types for each node group (private/public)"
  type        = list(string)
  default     = []
}

# 标签和污点配置
variable "node_labels" {
  description = "List of labels for each node group"
  type        = list(map(string))
  default     = []
}

variable "node_tags" {
  description = "List of tags for each node group"
  type        = list(map(string))
  default     = []
}

variable "node_taints" {
  description = "List of taints for each node group"
  type        = list(list(object({
    key    = string
    value  = string
    effect = string
  })))
  default     = []
}
variable "ec2_ssh_key" {
  description = "EC2 SSH key pair name for EKS worker nodes"
  type        = string
  default     = ""
  
}



