variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "192.168.0.0/16"
}
variable "env" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"  # 可以根据需要修改或删除默认值
}
