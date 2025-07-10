variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-southeast-2"
}
variable "aws_profile" {
  description = "The AWS profile to use for authentication"
  type        = string
  default     = "default"
}
variable "azure_tenant_id" {
  description = "The Azure tenant ID"
  type        = string
  default     = ""
}
variable "azure_subscription_id" {
  description = "The Azure subscription ID"
  type        = string
  default     = ""
}
variable "env" {
  description = "The environment for the resources"
  type        = string
  default     = "dev"
}
