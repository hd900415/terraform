variable "env" {
  description = "Deployment environment name"
  type        = string
  default     = "game"    # 也可以删掉 default，由 tfvars 传入
}
variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {
    Project = "GameProject"
    Owner   = "DevOps Team"
  }
  
}
variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.32"  # 更新为最新版本
  
}
variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "eks-cluster-game"
}
