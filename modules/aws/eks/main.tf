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

# eks node group
resource "aws_eks_node_group" "main" {
  for_each = var.node_groups
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = each.key
  #node_group_name = "${var.cluster_name}-node-group-${var.env}"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }
  update_config {
    max_unavailable = 1
  }


  instance_types = each.value.instance_types
  capacity_type = each.value.capacity_type
  disk_size = each.value.disk_size

  # remote_access {
  #   ec2_ssh_key = var.ec2_ssh_key
  #   source_security_group_ids = [ aws_security_group.eks.id ]
  # }


  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-${each.key}-${var.env}"
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

