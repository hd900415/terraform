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
    web = {
      desired_size     = 2 # 期望实例数
      max_size         = 4 # 最大实例数
      min_size         = 1 # 最小实例数
      instance_types   = ["c5.large"] # 使用 c5.large 实例
      capacity_type    = "ON_DEMAND" # 使用按需实例
      disk_size        = 100 # 磁盘大小
      volume_type      = "gp3" # 使用通用 SSD
      ami_type         = "AL2_x86_64"   # 使用 Amazon Linux 2
      subnet_type      = "private" # 使用私有子网
      key_name         = "" # 如果需要 SSH 访问，可以设置为你的密钥名称
      max_unavailable  = 1  # 最大不可用实例数
      version          = "1.31" # EKS 节点组版本

      labels = {
        role = "web"
        env  = var.env
      } # 标签
      tags = {
        NodeGroup = "web"
        Environment = var.env
      } # 标签
    }
    worker = {
      desired_size     = 3 # 期望实例数
      max_size         = 6 # 最大实例数
      min_size         = 1 # 最小实例数
      instance_types   = ["t3.medium"]  # 使用 t3.medium 实例
      capacity_type    = "ON_DEMAND"  # 使用按需实例
      disk_size        = 50   # 磁盘大小
      volume_type      = "gp3"  # 使用通用 SSD
      ami_type         = "AL2_x86_64" # 使用 Amazon Linux 2
      subnet_type      = "private"  # 使用私有子网
      key_name         = "" # 如果需要 SSH 访问，可以设置为你的密钥名称
      max_unavailable  = 1 # 最大不可用实例数
      version          = "1.31" # EKS 节点组版本
      labels = {
        role = "worker"
        env  = var.env
      } # 标签
      tags = {
        NodeGroup = "worker"
        Environment = var.env
      }   # 标签
    }
  }
}

# module "aws_vpc" {
#   source    = "../../modules/aws/vpc"
#   providers = {
#     aws = aws.aws
#   }
#   env        = var.env
#   cidr_block = "192.168.0.0/16"
# }

# module "aws_ec2" {
#   source    = "../../modules/aws/ec2"
#   providers = {
#     aws = aws.aws
#   }
#   env        = var.env
#   vpc_id     = module.aws_vpc.vpc_id
#   # 实例配置
#   instance_count = length(local.instance_configs)
#   instance_names = keys(local.instance_configs)
#   instance_types = [for config in local.instance_configs : config.type]
#   amis           = [for config in local.instance_configs : config.ami]
#   volume_sizes   = [for config in local.instance_configs : config.volume_size]
#   # 网络配置
#   subnet_ids = [
#     for config in local.instance_configs :
#     module.aws_vpc.public_subnet_ids[config.subnet_index]
#   ]
#   # 安全组配置
#   # 注意：这里的安全组是从 aws_sg 模块中获取的
#   security_group_ids_list = [
#     for config in local.instance_configs :
#     module.aws_sg.security_groups_by_type[config.security_groups]
#   ]
#   # 其他配置
# }

# module "aws_sg" {
#   source    = "../../modules/aws/sg"
#   providers = {
#     aws = aws.aws
#   }
#   env     = var.env
#   vpc_id  = module.aws_vpc.vpc_id
# }



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
  cluster_name   = var.eks_cluster_name
  common_tags    = var.common_tags
}
# EKS 集群模块
module "eks" {
  source    = "../../modules/aws/eks"
  providers = {
    aws = aws.aws
  }
  cluster_name = var.eks_cluster_name
  kubernetes_version = var.kubernetes_version
  vpc_id       = module.eks_vpc.vpc_id
  private_subnet_ids = module.eks_vpc.private_subnet_ids
  public_subnet_ids  = module.eks_vpc.public_subnet_ids
  #subnet_ids   = module.eks_vpc.private_subnet_ids

  # 使用 locals 配置的节点组
  node_group_count = length(local.eks_node_configs)
  node_group_names = keys(local.eks_node_configs)
  
  # 节点组配置数组 (类似 EC2 的配置方式)
  desired_sizes    = [for config in local.eks_node_configs : config.desired_size] # 期望实例数
  max_sizes        = [for config in local.eks_node_configs : config.max_size] # 最大实例数
  min_sizes        = [for config in local.eks_node_configs : config.min_size] # 最小实例数
  instance_types   = [for config in local.eks_node_configs : config.instance_types] # 实例类型
  capacity_types   = [for config in local.eks_node_configs : config.capacity_type]  # 容量类型
  disk_sizes       = [for config in local.eks_node_configs : config.disk_size]  # 磁盘大小
  volume_types     = [for config in local.eks_node_configs : config.volume_type]  # 卷类型
  ami_types        = [for config in local.eks_node_configs : config.ami_type] # AMI 类型
  key_names        = [for config in local.eks_node_configs : config.key_name] # SSH 密钥名称
  max_unavailables = [for config in local.eks_node_configs : config.max_unavailable] # 最大不可用实例数
  node_group_versions = [for config in local.eks_node_configs : config.version]        # EKS 节点组版本
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

