output "instance_ids" {
  description = "List of EC2 instance IDs"
  value       = aws_instance.web[*].id
}

output "instance_names" {
  description = "List of names of the EC2 instances"
  value       = [for instance in aws_instance.web : instance.tags["Name"]]
}
output "instance_private_ips" {
  description = "List of private IP addresses of the EC2 instances"
  value       = aws_instance.web[*].private_ip
}

output "instance_public_ips" {
  description = "List of public IP addresses of the EC2 instances"
  value       = aws_instance.web[*].public_ip
}

output "instance_availability_zones" {
  description = "List of availability zones for the EC2 instances"
  value       = aws_instance.web[*].availability_zone
}

output "instance_security_group_ids" {
  description = "List of security group IDs associated with the EC2 instances"
  value       = aws_instance.web[*].vpc_security_group_ids
}

output "instance_tags" {
  description = "Map of tags associated with the EC2 instances"
  value       = aws_instance.web[*].tags
}

output "instance_key_name" {
  description = "Key name used for the EC2 instances"
  value       = aws_instance.web[*].key_name
}

output "instance_ami" {
  description = "AMI used for the EC2 instances"
  value       = aws_instance.web[*].ami
}

output "instance_type" {
  description = "Instance type of the EC2 instances"
  value       = aws_instance.web[*].instance_type
}

output "eip_public_ip" {
  description = "The public IP address of the Elastic IP"
  value       = aws_eip.web[*].public_ip
}

output "eip_allocation_id" {
  description = "The allocation ID of the Elastic IP"
  value       = aws_eip.web[*].allocation_id
}
output "eip_association_id" {
  description = "The association ID of the Elastic IP"
  value       = aws_eip_association.web[*].id
}

  # 保持调试输出不变
output "debug_subnet" {
  value = var.subnet_id
}
output "debug_security_group_ids" {
  value = var.security_group_ids_list
}