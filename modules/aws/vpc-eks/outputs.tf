output "vpc_id" {
  value = aws_vpc.eks.id
}

output "public_subnet_ids" {
  value = aws_subnet.eks_public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.eks_private[*].id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.eks_gateway.id
}
output "internet_gateway_id" {
  value = aws_internet_gateway.eks.id
}
output "eip_id" {
  value = aws_eip.eks_nat.id
}
output "vpc_name" {
  value = aws_vpc.eks.tags["Name"]
  description = "value of the VPC Name tag on the VPC"
}
output "eks_cluster_name" {
  value = var.cluster_name
  description = "Name of the EKS cluster"
}
output "vpc_cidr_block" {
  value = aws_vpc.eks.cidr_block
  description = "CIDR block of the VPC"
  sensitive = true
}
output "common_tags" {
  value = var.common_tags
  description = "Common tags applied to all resources"
  
}

output "public_subnets_cidrs" {
  value = var.public_subnets_cidrs
  description = "List of CIDR blocks for public subnets"
}
output "private_subnets_cidrs" {
  value = var.private_subnets_cidrs
  description = "List of CIDR blocks for private subnets"
}
output "availability_zones" {
  value = var.availability_zones
  description = "List of availability zones used for the subnets"
}
output "gateway_id" {
  value = aws_nat_gateway.eks_gateway.id
  description = "ID of the NAT Gateway"  
}
output "subnet_ids" {
  value = {
    public  = aws_subnet.eks_public[*].id
    private = aws_subnet.eks_private[*].id
  }
  description = "Map of subnet IDs for public and private subnets"
  
}
output "eip_allocation_id" {
  value = aws_eip.eks_nat.id
  description = "Allocation ID of the Elastic IP for the NAT Gateway"
  
}
output "eip_public_ip" {
  value = aws_eip.eks_nat.public_ip
  description = "Public IP of the Elastic IP for the NAT Gateway"
  
}

