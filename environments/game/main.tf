provider "aws" {
  alias   = "aws"
  region  = "sa-east-1"
  profile = "game"
}
# 实例配置映射
locals {
  instance_configs = {
    # web = {
    #   type           = "c5.2xlarge"
    #   ami            = "ami-004a7732acfcc1e2d"
    #   volume_size    = 200
    #   subnet_index   = 0
    #   security_groups = "whitelist"
    #   # tags = {
    #   #   Name = "web-${var.env}"
    #   # }
    # }
    # test = {
    #   type           = "c5.2xlarge"
    #   ami            = "ami-004a7732acfcc1e2d"
    #   volume_size    = 300
    #   subnet_index   = 1
    #   security_groups = "test"
    # }
  }
}

# EKS 节点组配置映射 (类似 EC2 的 locals 配置)
locals {
  eks_node_configs = {
    # web = {
    #   desired_size     = 2
    #   max_size         = 4
    #   min_size         = 1
    #   instance_types   = ["c5.large"]
    #   capacity_type    = "ON_DEMAND"
    #   disk_size        = 100
    #   volume_type      = "gp3"
    #   ami_type         = "AL2_x86_64"
    #   subnet_type      = "private"
    #   key_name         = "terraform-key"
    #   max_unavailable  = 1
    #   labels = {
    #     role = "web"
    #     env  = var.env
    #   }
    #   tags = {
    #     NodeGroup = "web"
    #     Environment = var.env
    #   }
    # }
    # worker = {
    #   desired_size     = 3
    #   max_size         = 6
    #   min_size         = 1
    #   instance_types   = ["t3.medium"]
    #   capacity_type    = "ON_DEMAND"
    #   disk_size        = 50
    #   volume_type      = "gp3"
    #   ami_type         = "AL2_x86_64"
    #   subnet_type      = "private"
    #   key_name         = "terraform-key"
    #   max_unavailable  = 1
    #   labels = {
    #     role = "worker"
    #     env  = var.env
    #   }
    #   tags = {
    #     NodeGroup = "worker"
    #     Environment = var.env
    #   }
    # }
    # gpu = {
    #   desired_size     = 1
    #   max_size         = 2
    #   min_size         = 0
    #   instance_types   = ["g4dn.xlarge"]
    #   capacity_type    = "SPOT"
    #   disk_size        = 100
    #   volume_type      = "gp3"
    #   ami_type         = "AL2_x86_64_GPU"
    #   subnet_type      = "private"
    #   key_name         = "terraform-key"
    #   max_unavailable  = 1
    #   taints = [
    #     {
    #       key    = "nvidia.com/gpu"
    #       value  = "true"
    #       effect = "NO_SCHEDULE"
    #     }
    #   ]
    #   labels = {
    #     role = "gpu"
    #     "nvidia.com/gpu" = "true"
    #     env  = var.env
    #   }
    #   tags = {
    #     NodeGroup = "gpu"
    #     Environment = var.env
    #   }
    # }
  }
}

module "aws_vpc" {
  source    = "../../modules/aws/vpc"
  providers = {
    aws = aws.aws
  }
  env        = var.env
  cidr_block = "192.168.0.0/16"
}

module "aws_ec2" {
  source    = "../../modules/aws/ec2"
  providers = {
    aws = aws.aws
  }
  env        = var.env
  vpc_id     = module.aws_vpc.vpc_id
  # 实例配置
  instance_count = length(local.instance_configs)
  instance_names = keys(local.instance_configs)
  instance_types = [for config in local.instance_configs : config.type]
  amis           = [for config in local.instance_configs : config.ami]
  volume_sizes   = [for config in local.instance_configs : config.volume_size]
  # 网络配置
  subnet_ids = [
    for config in local.instance_configs :
    module.aws_vpc.public_subnet_ids[config.subnet_index]
  ]
  # 安全组配置
  # 注意：这里的安全组是从 aws_sg 模块中获取的
  security_group_ids_list = [
    for config in local.instance_configs :
    module.aws_sg.security_groups_by_type[config.security_groups]
  ]
  # 其他配置
}

module "aws_sg" {
  source    = "../../modules/aws/sg"
  providers = {
    aws = aws.aws
  }
  env     = var.env
  vpc_id  = module.aws_vpc.vpc_id
}



#EKS VPC 模块
module "eks_vpc" {
  source    = "../../modules/aws/vpc-eks"
  providers = {
    aws = aws.aws
  }
  vpc_cidr_block = "10.0.0.0/16"
  public_subnets_cidrs = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnets_cidrs = ["10.0.2.0/24", "10.0.3.0/24"]
  # 其他配置
  availability_zones = ["sa-east-1a", "sa-east-1b"]

  env            = var.env
  cluster_name   = "eks-cluster-${var.env}"
  common_tags    = var.common_tags
}
# EKS 集群模块
module "eks" {
  source    = "../../modules/aws/eks"
  providers = {
    aws = aws.aws
  }
  cluster_name = "eks-cluster-${var.env}"
  kubernetes_version = "1.28"
  vpc_id       = module.eks_vpc.vpc_id
  private_subnet_ids = module.eks_vpc.private_subnet_ids
  public_subnet_ids  = module.eks_vpc.public_subnet_ids
  #subnet_ids   = module.eks_vpc.private_subnet_ids

  # 使用 locals 配置的节点组
  node_group_count = length(local.eks_node_configs)
  node_group_names = keys(local.eks_node_configs)
  
  # 节点组配置数组 (类似 EC2 的配置方式)
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
  # ec2_ssh_key = "terraform-key"
  endpoint_private_access = true
  public_access_cidrs = [ "0.0.0.0/0" ]

  cluster_log_types = [ "api", "audit", "authenticator", "controllerManager", "scheduler" ]

  common_tags = var.common_tags
}

