variable "env" {
  type = string
  description = "The environment for the resources"
  default = "dev"  # Default can be overridden in tfvars
}

variable "vpc_id" {
  type = string
  description = "VPC ID to associate with the security group"
  default = ""  # Default can be overridden
}
variable "office_ip_cidr" {
  type = string
  description = "CIDR block for office IP to allow SSH access"
  default = "83.110.180.135/32"
}
variable "whitelist_cidrs" {
  type = list(string)
  description = "List of CIDR blocks to whitelist for SSH access"
  default = ["83.110.180.135/32","5.5.5.5/32"]
}
