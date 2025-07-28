  # 变量定义
variable "env" {
  description = "Environment name"
  type        = string
  default     = "jinzhuan"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {
    "Environment" = "jinzhuan"
    "CreatedBy"   = "Terraform"
    "ManagedBy"   = "Terraform"
  }
}
variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "eks-cluster-${var.env}"
}
variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.32"  # 更新为最新版本
}
variable "node_group_version" {
  description = "Version for the EKS node groups"
  type        = list(string)
  default     = "1.32"  # 默认版本
  
}

