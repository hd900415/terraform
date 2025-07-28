resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks.arn
  version = var.kubernetes_version
  vpc_config {
    subnet_ids = concat(var.private_subnet_ids, var.public_subnet_ids)
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access = var.endpoint_public_access
    public_access_cidrs = var.public_access_cidrs
    security_group_ids = [ aws_security_group.eks.id ]
  }
  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }
  enabled_cluster_log_types = var.cluster_log_types
  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-${var.env}"
  })

  depends_on = [
    aws_iam_role_policy_attachment.eks_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_AmazonEKSServicePolicy,
    ]
}

# eks node group (使用 count 而非 for_each，类似 EC2 配置)
resource "aws_eks_node_group" "main" {
  count = var.node_group_count
  
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = var.node_group_names[count.index]
  node_role_arn   = aws_iam_role.eks_node.arn
  
  # 动态选择子网 (private 或 public)
  subnet_ids = var.subnet_types[count.index] == "public" ? var.public_subnet_ids : var.private_subnet_ids

  scaling_config {
    desired_size = var.desired_sizes[count.index]
    max_size     = var.max_sizes[count.index]
    min_size     = var.min_sizes[count.index]
  }
  
  update_config {
    max_unavailable = var.max_unavailables[count.index]
  }

  instance_types = var.instance_types[count.index]
  capacity_type  = var.capacity_types[count.index]
  disk_size      = var.disk_sizes[count.index]
  ami_type       = var.ami_types[count.index]

  # 远程访问配置 (如果提供了 key_name)
  dynamic "remote_access" {
    for_each = var.key_names[count.index] != "" ? [1] : []
    content {
      ec2_ssh_key = var.key_names[count.index]
      source_security_group_ids = [aws_security_group.eks_node.id]
    }
  }

  # 污点配置
  dynamic "taint" {
    for_each = var.node_taints[count.index]
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  # 标签配置
  labels = var.node_labels[count.index]

  tags = merge(var.common_tags, var.node_tags[count.index], {
    Name = "${var.cluster_name}-${var.node_group_names[count.index]}-${var.env}"
  })

  depends_on = [
    aws_iam_role_policy_attachment.eks_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_AmazonEKS_CNI_Policy,
  ]
}

# eks secure group
resource "aws_security_group" "eks" {
  vpc_id = var.vpc_id
  name_prefix = "${var.cluster_name}-eks-secure-group-${var.env}"

  # ingress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = var.public_access_cidrs
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-eks-secure-group-${var.env}"
  })
}

# EKS Node security group
resource "aws_security_group" "eks_node" {
  vpc_id = var.vpc_id
  name_prefix = "${var.cluster_name}-eks-node-secure-group-${var.env}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [aws_security_group.eks.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-eks-node-secure-group-${var.env}"
  })
}
# KMS Key for EKS Secrets Encryption
resource "aws_kms_key" "eks" {
  description = "KMS key for EKS secrets encryption"
  deletion_window_in_days = 7
  enable_key_rotation = true

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-kms-key-${var.env}"
  })
}

