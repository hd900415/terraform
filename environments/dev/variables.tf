variable "env" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"    # 也可以删掉 default，由 tfvars 传入
}
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {
    "CreatedBy" = "Terraform"
    "ManagedBy" = "Terraform"
  }
  
}


variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "eks-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.31"
  
}

