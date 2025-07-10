variable "env" {
  description = "Deployment environment name"
  type        = string
  default     = "prod"    # 也可以删掉 default，由 tfvars 传入
}
