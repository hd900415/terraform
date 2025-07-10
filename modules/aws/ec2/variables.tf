variable "subnet_id" {
  type        = string
  description = "Subnet ID to launch the EC2 instance in"
  default     = "" # Default can be overridden
}
# variable "security_group_ids" {
#   type = list(string)
#   description = "List of security group IDs to associate with the EC2 instance"
#   #default     = [aws_security_group.web.id]
# }
variable "env" {
  type        = string
  description = "The environment for the resources"
  default     = "dev"
}
variable "vpc_id" {
  type = string
  description = "value of vpc_id from aws_vpc module"
}

variable "instance_count" {
  type        = number
  description = "Number of EC2 instances to launch"
  default     = 1
}
variable "instance_names" {
  type        = list(string)
  description = "Name of the EC2 instances"
  default     = ["ec2-instance"]
}
variable "instance_types" {
  type        = list(string)
  description = "Type of EC2 instances to launch"
  default     = ["c5.2xlarge"] # Default instance type
}
variable "amis" {
  type        = list(string)
  description = "List of AMI IDs to use for the EC2 instances"
  default     = ["ami-004a7732acfcc1e2d"] # Default AMI ID for Amazon Linux 2 in ap-southeast-1
}
variable "volume_sizes" {
  type        = list(number)
  description = "List of volume sizes for the EC2 instances"
  default     = [100] # Default volume size in GB
}
variable "security_group_ids_list" {
  type        = list(list(string))
  description = "List of security group IDs to associate with the EC2 instances"
  default     = [[]] # Default can be overridden
}
variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to launch the EC2 instances in"
  default     = [""] # Default can be overridden
}
variable "instance_tags" {
  type        = map(string)
  description = "Map of tags to apply to the EC2 instances"
  default     = {
    Name = ""
  }
}