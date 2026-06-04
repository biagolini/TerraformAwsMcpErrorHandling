# ============================================================================
# Outputs
# ============================================================================

output "api_endpoint" {
  description = "API Gateway endpoint URL for the MCP server"
  value       = "${aws_apigatewayv2_api.mcp.api_endpoint}/mcp"
}

output "table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.cars.name
}

output "api_id" {
  description = "API Gateway ID (needed for IAM policy)"
  value       = aws_apigatewayv2_api.mcp.id
}
