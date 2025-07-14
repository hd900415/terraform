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
  cluster_name = "game-eks-cluster"
  kubernetes_version = "1.33"
  vpc_id       = module.eks_vpc.vpc_id
  private_subnet_ids = module.eks_vpc.private_subnet_ids
  public_subnet_ids  = module.eks_vpc.public_subnet_ids
  #subnet_ids   = module.eks_vpc.private_subnet_ids

  # EKS Worker Node 配置
  node_groups = {
    worker_nodes = {
      desired_size   = 2
      max_size       = 3
      min_size       = 1
      instance_types = ["m5.large"]
      capacity_type  = "ON_DEMAND"
      disk_size      = 100
      #subnet_ids     = module.eks_vpc.private_subnet_ids
      #security_groups = [aws_security_group.eks_node.id]
    }
    eks_nodes = {
      desired_size   = 2
      max_size       = 3
      min_size       = 1
      instance_types = ["c5.xlarge"]
      capacity_type  = "ON_DEMAND"
      disk_size      = 280
      max_unavailable = 1 # 可选，默认值为 1
    }
  }
  # ec2_ssh_key = "terraform-key"
  endpoint_private_access = true
  public_access_cidrs = [ "0.0.0.0/0" ]

  cluster_log_types = [ "api", "audit", "authenticator", "controllerManager", "scheduler" ]

  common_tags = var.common_tags
}

