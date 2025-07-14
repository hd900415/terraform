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