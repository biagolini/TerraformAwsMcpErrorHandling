# ============================================================================
# Locals
# ============================================================================

locals {
  default_tags = {
    project_id  = var.project_id
    managed_by  = "terraform"
    environment = var.environment
  }
}
