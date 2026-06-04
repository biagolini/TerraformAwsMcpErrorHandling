# ============================================================================
# DynamoDB
# ============================================================================

resource "aws_dynamodb_table" "cars" {
  name         = "${var.project_prefix}-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "car_id"

  attribute {
    name = "car_id"
    type = "S"
  }

  attribute {
    name = "body_type"
    type = "S"
  }

  global_secondary_index {
    name            = "body-type-index"
    hash_key        = "body_type"
    projection_type = "ALL"
  }
}
