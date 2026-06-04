# ============================================================================
# Variables
# ============================================================================

variable "project_prefix" {
  description = "Project identifier prefix for all resource names"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project_id" {
  description = "Project identifier for cost allocation tags"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}
