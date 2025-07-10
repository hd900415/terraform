resource "aws_eks_cluster" "existing_cluster" {
  name     = "eks-cluster"
  role_arn = "arn:aws:iam::715841329711:role/eksctl-eks-cluster-cluster-ServiceRole-0k3juONWCXTm"
  version  = "1.32"

  bootstrap_self_managed_addons = false

  vpc_config {
    subnet_ids              = [
      "subnet-04853b8df1d5ea31f",
      "subnet-0293b3d861a449cf0", 
      "subnet-0c9e9c1ef6482bb1c",
      "subnet-0ddba3cca787f1743",
      "subnet-087c709f197b6d750",
      "subnet-0db056d670b4fd913"
    ]
    endpoint_private_access = false
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
    security_group_ids      = ["sg-0c56271ef83bf9293"]
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  kubernetes_network_config {
    service_ipv4_cidr = "172.20.0.0/16"
    ip_family         = "ipv4"
  }

  upgrade_policy {
    support_type = "EXTENDED"
  }

  tags = {
    "Name"                                        = "eksctl-eks-cluster-cluster/ControlPlane"
    "alpha.eksctl.io/cluster-name"                = "eks-cluster"
    "alpha.eksctl.io/cluster-oidc-enabled"        = "true"
    "alpha.eksctl.io/eksctl-version"              = "0.204.0"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "eks-cluster"
  }
}

resource "aws_eks_node_group" "existing_nodegroup" {
  cluster_name    = aws_eks_cluster.existing_cluster.name
  node_group_name = "eks-cluster-nodegroup-1"
  node_role_arn   = "arn:aws:iam::715841329711:role/eksctl-eks-cluster-nodegroup-eks-c-NodeInstanceRole-cpl3diBALL6C"
  subnet_ids      = [
    "subnet-0c9e9c1ef6482bb1c",
    "subnet-04853b8df1d5ea31f", 
    "subnet-0293b3d861a449cf0"
  ]

  scaling_config {
    desired_size = 10
    max_size     = 20
    min_size     = 2
  }

  ami_type       = "AL2_x86_64"
  instance_types = ["c5a.4xlarge"]

  launch_template {
    id      = "lt-062a01217544e9718"
    version = "1"
  }

  labels = {
    "alpha.eksctl.io/cluster-name"   = "eks-cluster"
    "alpha.eksctl.io/nodegroup-name" = "eks-cluster-nodegroup-1"
  }

  tags = {
    "alpha.eksctl.io/cluster-name"                = "eks-cluster"
    "alpha.eksctl.io/eksctl-version"              = "0.204.0"
    "alpha.eksctl.io/nodegroup-name"              = "eks-cluster-nodegroup-1"
    "alpha.eksctl.io/nodegroup-type"              = "managed"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "eks-cluster"
  }
}

# Note: IAM roles and policy attachments are managed by eksctl
# and should not be managed by Terraform to avoid conflicts