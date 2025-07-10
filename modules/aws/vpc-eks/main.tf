# EKS 专用 VPC
resource "aws_vpc" "eks" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = merge(var.common_tags,{
    Name = "eks-vpc-${var.env}"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    })
}
# Internet Gateway
resource "aws_internet_gateway" "eks" {
  vpc_id = aws_vpc.eks.id

  tags = merge(var.common_tags, {
    Name = "eks-igw-${var.env}"
  })
}
# 公共子网（用于 NAT Gateway 和 Load Balancer）
resource "aws_subnet" "eks_public" {
  count = length(var.public_subnets_cidrs)

  vpc_id            = aws_vpc.eks.id
  cidr_block        = var.public_subnets_cidrs[count.index]
  availability_zone = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
      Name = "eks-public-subnet-${count.index + 1}-${var.env}"
      "kubernetes.io/role/elb" = "1"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    })
}
# 私有子网（用于 EKS Worker Nodes）
resource "aws_subnet" "eks_private" {
  count = length(var.private_subnets_cidrs)

  vpc_id            = aws_vpc.eks.id
  cidr_block        = var.private_subnets_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.common_tags, {
    Name = "eks-private-subnet-${count.index + 1}-${var.env}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  })
}

# Elastic IP for NAT Gateway
resource "aws_eip" "eks_nat" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.eks]
  tags = merge(var.common_tags, {
    Name = "eks-nat-eip-${var.env}"
  })
}

# NAT Gateway (单个，所有私有子网共享同一个出口 IP)
resource "aws_nat_gateway" "eks_gateway" {
  allocation_id = aws_eip.eks_nat.id
  subnet_id     = aws_subnet.eks_public[0].id
  depends_on    = [aws_internet_gateway.eks]

  tags = merge(var.common_tags, {
    Name = "eks-nat-gateway-${var.env}"
  })
}

# Route Table for Public Subnets (公共子网路由表)
resource "aws_route_table" "eks_public" {
  vpc_id = aws_vpc.eks.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks.id
  }

  tags = merge(var.common_tags, {
    Name = "eks-public-route-table-${var.env}"
  })
}
resource "aws_route_table" "eks_private" {
  vpc_id = aws_vpc.eks.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.eks_gateway.id
  }

  tags = merge(var.common_tags, {
    Name = "eks-private-route-table-${var.env}"
  })
}

# Associate Public Subnets with Route Table (公共子网路由表关联)
resource "aws_route_table_association" "eks_public" {
  count          = length(aws_subnet.eks_public)
  subnet_id      = aws_subnet.eks_public[count.index].id
  route_table_id = aws_route_table.eks_public.id
}

# Associate Private Subnets with Route Table (私有子网路由表关联)
resource "aws_route_table_association" "eks_private" {
  count          = length(aws_subnet.eks_private)
  subnet_id      = aws_subnet.eks_private[count.index].id
  route_table_id = aws_route_table.eks_private.id
}

