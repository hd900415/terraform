output "namespace_info" {
  description = "Namespace information for the EKS cluster"
  value = {
    namespace_name = module.eks.namespace_name
    namespace_arn  = module.eks.namespace_arn
  }
  
}
output "namespace_labels" {
  description = "Labels applied to the EKS namespace"
  value = module.eks.namespace_labels
  
}
output "eks_cluster_info" {
  description = "EKS cluster information"
  value = {
    cluster_name       = module.eks.cluster_name
    cluster_endpoint   = module.eks.cluster_endpoint
    cluster_version    = module.eks.cluster_version
    cluster_security_group_id = module.eks.cluster_security_group_id
    node_group_names   = module.eks.node_group_names
    node_group_arns    = module.eks.node_group_arns
  }
} 
output "eks_node_group_info" {
  description = "EKS node group information"
  value = {
    node_group_names   = module.eks.node_group_names
    node_group_arns    = module.eks.node_group_arns
    node_group_statuses = module.eks.node_group_statuses
    node_group_desired_sizes = module.eks.node_group_desired_sizes
  }
}
output "namespace_creation_commands" {
  description = "Commands to create the EKS namespace"
  value = [
    for ns in module.eks.namespace_creation_commands :
    "kubectl create namespace ${ns.namespace_name} --dry-run=client -o yaml | kubectl apply -f -"
  ]
  
}
output "namespace_deletion_commands" {
  description = "Commands to delete the EKS namespace"
  value = [
    for ns in module.eks.namespace_deletion_commands :
    "kubectl delete namespace ${ns.namespace_name}"
  ]
  
}
output "namespace_labels_commands" {
  description = "Commands to apply labels to the EKS namespace"
  value = [
    for ns in module.eks.namespace_labels_commands :
    "kubectl label namespace ${ns.namespace_name} ${ns.labels}"
  ]
  
}
output "namespace_annotations_commands" {
  description = "Commands to apply annotations to the EKS namespace"
  value = [
    for ns in module.eks.namespace_annotations_commands :
    "kubectl annotate namespace ${ns.namespace_name} ${ns.annotations}"
  ]
  
}
output "eks_cluster_logs" {
  description = "EKS cluster logs configuration"
  value = {
    enabled_log_types = module.eks.enabled_log_types
    log_group_name    = module.eks.log_group_name
  }
}
output "namespace_logs" {
  description = "Logs configuration for the EKS namespace"
  value = {
    enabled_log_types = module.eks.namespace_enabled_log_types
    log_group_name    = module.eks.namespace_log_group_name
  }
  
}
output "namespace_resource_limits" {
  description = "Resource limits for the EKS namespace"
  value = {
    cpu_limit    = module.eks.namespace_cpu_limit
    memory_limit = module.eks.namespace_memory_limit
  }
  
}
output "namespace_resource_requests" {
  description = "Resource requests for the EKS namespace"
  value = {
    cpu_request    = module.eks.namespace_cpu_request
    memory_request = module.eks.namespace_memory_request
  }
  
}
output "namespace_quota" {
  description = "Resource quota for the EKS namespace"
  value = {
    cpu_quota    = module.eks.namespace_cpu_quota
    memory_quota = module.eks.namespace_memory_quota
  }
  
}
