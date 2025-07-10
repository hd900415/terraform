  # ====================
  # EKS 集群 IAM 角色
  # ====================
resource "aws_iam_role" "eks" {
  name = "${var.cluster_name}-eks-cluster-role-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = merge(
    var.common_tags,
    {
      "Name" = "${var.cluster_name}-eks-cluster-role-${var.env}"
    }
  )
}
# EKS 集群策略附加
resource "aws_iam_role_policy_attachment" "eks_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}
# EKS 服务策略附加（某些区域需要）
resource "aws_iam_role_policy_attachment" "eks_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks.name
}
# ====================
# EKS 节点组 IAM 角色
# ====================
resource "aws_iam_role" "eks_node" {
  #for_each = var.node_groups

  name = "${var.cluster_name}-eks-node-role-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-eks-node-role--${var.env}"
  })
}
# Worker Node 策略附加
resource "aws_iam_role_policy_attachment" "eks_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node.name
}
# CNI 策略附加
resource "aws_iam_role_policy_attachment" "eks_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node.name
}
# ECR 策略附加
resource "aws_iam_role_policy_attachment" "eks_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node.name
}
# ====================
# 实例配置文件（如果需要）
# ====================
resource "aws_iam_instance_profile" "eks_node" {
  #for_each = var.node_groups

  name = "${var.cluster_name}-eks-node-profile-${var.env}"
  role = aws_iam_role.eks_node.name

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-eks-node-profile-${var.env}"
  })
  
}






