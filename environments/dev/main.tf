# ============================================================================
# Environment: dev
# ============================================================================

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI profile name"
  type        = string
}

locals {
  default_tags = {
    project_id  = "TerraformAwsMcpErrorHandling"
    managed_by  = "terraform"
    environment = "dev"
  }
}

module "main" {
  source = "../../infrastructure"

  project_prefix = "mcp-error-handling"
  aws_region     = var.aws_region
  project_id     = "TerraformAwsMcpErrorHandling"
  environment    = "dev"
}

# ============================================================================
# Outputs
# ============================================================================

output "api_endpoint" {
  value = module.main.api_endpoint
}

output "table_name" {
  value = module.main.table_name
}

output "api_id" {
  value = module.main.api_id
}
