# 多云 Terraform 基础设施项目

这是一个支持多云、多环境部署的 Terraform 基础设施即代码项目。

## 🏗️ 项目结构

```
terraform/
├── README.md                    # 项目说明文档
├── versions.tf                  # Terraform 版本要求
├── environments/                # 环境配置目录
│   ├── dev/                    # 开发环境
│   │   ├── backend.tf          # 后端存储配置
│   │   ├── main.tf             # 主配置文件
│   │   ├── terraform.tfvars    # 变量值文件
│   │   └── variables.tf        # 变量定义
│   └── prod/                   # 生产环境
│       ├── backend.tf          # 后端存储配置
│       ├── main.tf             # 主配置文件
│       ├── required_providers.tf # Provider 版本要求
│       └── terraform.tfvars    # 变量值文件
├── modules/                    # 可复用模块目录
│   ├── aws/                    # AWS 云服务模块
│   │   ├── ec2/                # EC2 实例模块
│   │   │   ├── main.tf         # EC2 资源定义
│   │   │   ├── variables.tf    # 输入变量
│   │   │   └── outputs.tf      # 输出值
│   │   ├── vpc/                # VPC 网络模块
│   │   │   ├── main.tf         # VPC 资源定义
│   │   │   ├── variables.tf    # 输入变量
│   │   │   └── outputs.tf      # 输出值
│   │   └── sg/                 # 安全组模块
│   │       ├── main.tf         # 安全组资源定义
│   │       ├── variables.tf    # 输入变量
│   │       └── outputs.tf      # 输出值
│   ├── azure/                  # Azure 云服务模块
│   │   ├── vm/                 # 虚拟机模块
│   │   └── vnet/               # 虚拟网络模块
│   ├── gcp/                    # GCP 云服务模块
│   └── hw/                     # 华为云模块
├── shared/                     # 共享配置
│   ├── providers.tf            # 云服务提供商配置
│   └── variables.tf            # 全局变量定义
├── infrastructure/             # 基础设施状态
│   ├── bootstrap/              # 引导配置
│   └── 3/                      # 其他基础设施
└── output/                     # 输出文件
    └── plan.out               # Terraform 计划文件
```

## 🚀 快速开始

### 前置条件

1. 安装 [Terraform](https://www.terraform.io/downloads.html) (>= 1.6.0)
2. 配置相应的云服务提供商凭证：
   - AWS: 配置 AWS CLI 或设置环境变量
   - Azure: 配置 Azure CLI 或设置环境变量
   - GCP: 配置 gcloud CLI 或设置服务账户密钥

### 部署步骤

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd terraform
   ```

2. **选择环境**
   ```bash
   cd environments/dev  # 或 environments/prod
   ```

3. **初始化 Terraform**
   ```bash
   terraform init
   ```

4. **检查配置**
   ```bash
   terraform plan
   ```

5. **应用配置**
   ```bash
   terraform apply
   ```

## 🔧 配置说明

### 环境变量配置

在 `environments/{env}/terraform.tfvars` 文件中设置环境特定的变量：

```hcl
# 环境标识
env = "dev"

# AWS 配置
aws_region = "ap-southeast-1"
aws_profile = "default"

# Azure 配置
azure_tenant_id = "your-tenant-id"
azure_subscription_id = "your-subscription-id"
```

### 如何配置 EC2 实例

要配置一个 EC2 实例，需要编辑以下文件：

#### 1. 环境配置文件 (`environments/{env}/main.tf`)

```hcl
# 调用 EC2 模块
module "aws_ec2" {
  source             = "../../modules/aws/ec2"
  env                = var.env
  subnet_id          = module.aws_vpc.public_subnet_ids[0]
  vpc_id             = module.aws_vpc.vpc_id
  security_group_ids = module.aws_sg.security_group_ids
  ami                = "ami-0a3ece531caa5d49d"  # 可选：指定 AMI ID
}
```

#### 2. EC2 模块变量 (`modules/aws/ec2/variables.tf`)

可以修改以下变量的默认值：

```hcl
variable "ami" {
  type        = string
  description = "AMI ID to use for the EC2 instance"
  default     = "ami-0a3ece531caa5d49d"  # 修改默认 AMI
}

# 其他可配置变量...
```

#### 3. EC2 模块主配置 (`modules/aws/ec2/main.tf`)

可以修改实例类型、存储配置等：

```hcl
resource "aws_instance" "web" {
  ami                    = var.ami
  instance_type          = "c5.2xlarge"    # 修改实例类型
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = "terraform-key"  # 修改密钥名称
  
  root_block_device {
    volume_type = "gp3"
    volume_size = 100     # 修改存储大小
  }

  tags = {
    Name = "ec2-${var.env}"
  }
}
```

#### 4. 环境变量文件 (`environments/{env}/terraform.tfvars`)

```hcl
# 可以在这里覆盖模块变量
ami = "ami-custom-id"
```

## 🌐 多云支持

### AWS 配置

确保已配置 AWS 凭证：
```bash
aws configure
# 或设置环境变量
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="ap-southeast-1"
```

### Azure 配置

确保已配置 Azure 凭证：
```bash
az login
# 或设置环境变量
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"
```

## 📁 模块说明

### AWS 模块

- **VPC 模块** (`modules/aws/vpc/`)
  - 创建 VPC、子网、Internet Gateway
  - 配置路由表和路由表关联
  - 支持多可用区部署

- **EC2 模块** (`modules/aws/ec2/`)
  - 创建 EC2 实例
  - 自动分配 EIP（弹性 IP）
  - 支持自定义 AMI、实例类型、存储配置

- **安全组模块** (`modules/aws/sg/`)
  - Web 安全组：允许 HTTP/HTTPS 访问
  - 办公网安全组：允许办公网 IP 访问

## 🔐 安全注意事项

1. **敏感信息管理**
   - 不要在代码中硬编码敏感信息
   - 使用环境变量或 Terraform 变量文件
   - 将 `terraform.tfvars` 文件添加到 `.gitignore`

2. **访问控制**
   - 定期审查安全组规则
   - 使用最小权限原则
   - 定期轮换访问密钥

3. **状态文件**
   - 使用远程后端存储状态文件
   - 启用状态文件加密
   - 控制状态文件访问权限

## 🚨 常见问题

### Q: 如何切换环境？
A: 切换到对应的环境目录，如 `cd environments/prod`，然后执行 Terraform 命令。

### Q: 如何添加新的资源？
A: 在对应的模块中添加资源定义，或在环境配置中调用新的模块。

### Q: 如何管理多个 AWS 账户？
A: 在不同环境的 `terraform.tfvars` 中配置不同的 `aws_profile`。

### Q: 如何销毁资源？
A: 在对应环境目录中运行 `terraform destroy`。

## 📝 最佳实践

1. **版本控制**
   - 使用 Git 管理代码
   - 为重要变更打标签
   - 使用分支管理不同功能

2. **模块化**
   - 保持模块的单一职责
   - 使用描述性的变量名
   - 提供完整的输出值

3. **文档**
   - 为每个模块编写清晰的文档
   - 使用有意义的变量描述
   - 保持 README 文件更新

4. **测试**
   - 在应用到生产环境前先在开发环境测试
   - 使用 `terraform plan` 检查变更
   - 定期验证基础设施状态

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支
3. 提交变更
4. 创建 Pull Request

## 📄 许可证

[MIT License](LICENSE)


 � 实用查看命令

  快速获取连接信息

  # 获取 SSH 连接命令
  terraform output ssh_commands

  # 获取实例概览
  terraform output web_instance_info

  监控和管理

  # 查看资源变化（不执行）
  terraform plan

  # 刷新状态并显示输出
  terraform refresh && terraform output

  # 导出状态到 JSON 文件
  terraform show -json > infrastructure.json

  � 添加新服务器后的查看流程

  1. 部署后立即查看
  terraform apply
  # 部署完成后会自动显示输出

  2. 随时查看当前状态
  terraform output

  3. 获取特定信息
  # 新实例的 IP
  terraform output eip_public_ip

  # 新实例的 ID  
  terraform output instance_ids

  � 实用技巧

  1. 保存输出到文件

  terraform output > infrastructure-info.txt

  2. 在脚本中使用输出

  # 获取 IP 用于其他脚本
  PUBLIC_IP=$(terraform output -raw eip_public_ip | jq -r '.[0]')
  echo "Connecting to: $PUBLIC_IP"

  3. 实时监控

  # 每30秒刷新一次状态
  watch -n 30 'terraform output web_instance_info'

  这样您就可以随时查看基础设施的状态和连接信息了！