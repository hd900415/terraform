# Terraform 代码执行流程说明

## 概述

本文档详细说明了该 Terraform 项目的代码执行流程，包括模块调用关系、资源创建顺序以及依赖关系。

## 项目架构

```
terraform/
├── environments/
│   ├── dev/
│   │   ├── main.tf          # 开发环境入口文件
│   │   ├── variables.tf     # 开发环境变量定义
│   │   └── backend.tf       # 后端存储配置
│   └── prod/
│       ├── main.tf          # 生产环境入口文件
│       ├── variables.tf     # 生产环境变量定义
│       └── backend.tf       # 后端存储配置
└── modules/
    └── aws/
        ├── vpc/             # VPC 模块
        ├── ec2/             # EC2 模块 (包含 EIP)
        └── sg/              # 安全组模块
```

## 执行流程详解

### 1. 环境入口 (environments/dev/main.tf)

执行从环境级别的 `main.tf` 开始：

```hcl
# Provider 配置 - 指定部署区域
provider "aws" {
  alias   = "aws"
  region  = "ap-southeast-1"  # 新加坡区域
  profile = "default"
}
```

### 2. 模块调用顺序

Terraform 根据依赖关系自动确定资源创建顺序：

#### 2.1 VPC 模块调用
```hcl
module "aws_vpc" {
  source    = "../../modules/aws/vpc"
  providers = {
    aws = aws.aws  # 传递 provider 配置
  }
  env        = var.env
  cidr_block = "192.168.0.0/16"
}
```

**创建的资源：**
- VPC (192.168.0.0/16)
- 公共子网 (ap-southeast-1a: 192.168.0.0/24, ap-southeast-1b: 192.168.1.0/24)
- Internet Gateway
- 路由表和路由表关联

#### 2.2 安全组模块调用
```hcl
module "aws_sg" {
  source    = "../../modules/aws/sg"
  providers = {
    aws = aws.aws
  }
  env     = var.env
  vpc_id  = module.aws_vpc.vpc_id  # 依赖 VPC 模块输出
}
```

**创建的资源：**
- Web 安全组 (允许 HTTP/HTTPS 入站流量)
- Office 安全组 (允许特定 IP SSH 访问)

#### 2.3 EC2 模块调用
```hcl
module "aws_ec2" {
  source    = "../../modules/aws/ec2"
  providers = {
    aws = aws.aws
  }
  env        = var.env
  subnet_id  = module.aws_vpc.public_subnet_ids[0]    # 依赖 VPC 模块输出
  vpc_id     = module.aws_vpc.vpc_id                  # 依赖 VPC 模块输出
  security_group_ids = module.aws_sg.security_group_ids  # 依赖安全组模块输出
}
```

**创建的资源：**
- EC2 实例 (c5.2xlarge, 使用新加坡区域 AMI)
- Elastic IP (EIP)
- EIP 关联 (将 EIP 绑定到 EC2 实例)

## 3. 资源依赖关系图

```
VPC 模块
├── aws_vpc.main
├── aws_subnet.public[0,1]
├── aws_internet_gateway.main
├── aws_route_table.public
└── aws_route_table_association.public[0,1]
    │
    ├─→ 安全组模块 (依赖 VPC ID)
    │   ├── aws_security_group.web
    │   └── aws_security_group.Allow-from-office
    │
    └─→ EC2 模块 (依赖 VPC 子网和安全组)
        ├── aws_eip.web
        ├── aws_instance.web
        └── aws_eip_association.web
```

## 4. 执行命令和阶段

### 4.1 初始化阶段
```bash
terraform init
```
- 下载 AWS Provider
- 初始化后端存储 (S3)
- 初始化模块

### 4.2 规划阶段
```bash
terraform plan
```
- 分析依赖关系
- 生成执行计划
- 显示将要创建的资源

### 4.3 应用阶段
```bash
terraform apply
```
**实际执行顺序：**
1. **并行创建：** VPC 和 EIP (无依赖)
2. **依赖 VPC：** Internet Gateway, 子网, 安全组
3. **依赖 IGW：** 路由表
4. **依赖子网：** 路由表关联
5. **依赖子网和安全组：** EC2 实例
6. **依赖 EC2 和 EIP：** EIP 关联

## 5. 模块间数据传递

### VPC 模块输出 (outputs.tf)
```hcl
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}
```

### 安全组模块输出
```hcl
output "security_group_ids" {
  value = [aws_security_group.web.id, aws_security_group.Allow-from-office.id]
}
```

### EC2 模块输出
```hcl
output "instance_id" {
  value = aws_instance.web.id
}

output "public_ip" {
  value = aws_eip.web.public_ip
}
```

## 6. Provider 配置传递机制

为确保所有模块使用正确的 AWS 区域，使用 `providers` 块传递配置：

```hcl
module "module_name" {
  providers = {
    aws = aws.aws  # 将主配置的 provider 传递给模块
  }
}
```

这确保了所有资源都在 ap-southeast-1 (新加坡) 区域创建。

## 7. 状态管理

- **本地状态：** 开发时存储在本地 `.terraform` 目录
- **远程状态：** 生产环境使用 S3 后端存储状态文件
- **状态锁：** 通过 DynamoDB 防止并发修改

## 8. 环境管理

- **开发环境：** `environments/dev/` - 使用较小的实例和简化配置
- **生产环境：** `environments/prod/` - 可配置更高规格和额外安全措施
- **变量管理：** 通过 `variables.tf` 和环境特定的 `.tfvars` 文件

## 9. 安全最佳实践

1. **最小权限原则：** 安全组仅开放必要端口
2. **网络隔离：** 使用 VPC 和子网进行网络分段
3. **访问控制：** 通过 SSH 密钥和特定 IP 限制访问
4. **加密存储：** EBS 卷可配置加密 (在生产环境中建议启用)

## 10. 扩展和维护

### 添加新资源
1. 在相应模块中添加资源定义
2. 更新模块的 outputs.tf (如需要)
3. 在环境配置中调用新的模块参数

### 跨区域部署
1. 修改 provider 区域配置
2. 更新 AMI ID 为目标区域的 AMI
3. 更新可用区配置

### 多环境管理
1. 复制环境目录结构
2. 修改环境特定的变量值
3. 使用不同的后端存储配置

这个流程确保了基础设施的一致性、可重复性和可维护性。