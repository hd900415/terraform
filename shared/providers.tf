provider "aws" {
  alias   = "aws"
  region  = var.aws_region
  profile = var.aws_profile
}

provider "azurerm" {
  alias           = "azure"
  #features        = {}
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
}
