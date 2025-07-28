
  # Provider配置
  provider "aws" {
    alias   = "aws"
    region  = "ap-east-1"
    profile = "jz"
  }
# EKS节点组配置映射
  locals {
    eks_node_configs = {
      nodegroup-2 = {
        desired_size     = 5
        max_size         = 20
        min_size         = 2
        instance_types   = ["c5.2xlarge"]
        capacity_type    = "ON_DEMAND"
        disk_size        = 200
        volume_type      = "gp3"
        ami_type         = "AL2023_x86_64_STANDARD"
        subnet_type      = "private"
        key_name         = ""
        max_unavailable  = 1
        labels = {
          role = "worker"
          env  = var.env
        }
        tags = {
          NodeGroup = "nodegroup-2"
          Environment = var.env
        }
      }
    }
  }

  # 引用现有VPC
  data "aws_vpc" "existing" {
    id = "vpc-0592f68047ac98d6a"
  }

  # 引用现有子网
  data "aws_subnet" "private_1" {
    id = "subnet-00d03858c60bd4803"
  }

  data "aws_subnet" "private_2" {
    id = "subnet-0bb84f37eef2b5a54"
  }

  data "aws_subnet" "private_3" {
    id = "subnet-098c8c3b0e2bc7e7d"
  }

  # EKS集群模块
  module "eks" {
    source    = "../../modules/aws/eks"
    providers = {
      aws = aws.aws
    }
    
    cluster_name       = "eks-hk"
    kubernetes_version = "1.32"
    vpc_id            = data.aws_vpc.existing.id
    private_subnet_ids = [
      data.aws_subnet.private_1.id,
      data.aws_subnet.private_2.id,
      data.aws_subnet.private_3.id
    ]
    public_subnet_ids = [] # 当前集群只使用私有子网

    # 使用locals配置的节点组
    node_group_count = length(local.eks_node_configs)
    node_group_names = keys(local.eks_node_configs)
    
    # 节点组配置数组
    desired_sizes    = [for config in local.eks_node_configs : config.desired_size]
    max_sizes        = [for config in local.eks_node_configs : config.max_size]
    min_sizes        = [for config in local.eks_node_configs : config.min_size]
    instance_types   = [for config in local.eks_node_configs : config.instance_types]
    capacity_types   = [for config in local.eks_node_configs : config.capacity_type]
    disk_sizes       = [for config in local.eks_node_configs : config.disk_size]
    volume_types     = [for config in local.eks_node_configs : config.volume_type]
    ami_types        = [for config in local.eks_node_configs : config.ami_type]
    key_names        = [for config in local.eks_node_configs : config.key_name]
    max_unavailables = [for config in local.eks_node_configs : config.max_unavailable]
    
    # 子网配置
    subnet_types = [for config in local.eks_node_configs : config.subnet_type]
    
    # 标签和污点配置
    node_labels = [for config in local.eks_node_configs : config.labels]
    node_tags   = [for config in local.eks_node_configs : config.tags]
    node_taints = [for config in local.eks_node_configs : lookup(config, "taints", [])]

    # 集群访问配置
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]

    # 日志配置（当前集群日志已禁用）
    cluster_log_types = []

    common_tags = var.common_tags
  }
