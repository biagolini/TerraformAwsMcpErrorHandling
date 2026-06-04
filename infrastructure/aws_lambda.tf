# ============================================================================
# Lambda
# ============================================================================

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/src/lambda"
  output_path = "${path.module}/.temp/lambda.zip"
}

resource "aws_lambda_function" "mcp_server" {
  filename         = data.archive_file.lambda.output_path
  function_name    = "${var.project_prefix}-server-${var.environment}"
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  runtime          = "python3.12"
  timeout          = 5
  memory_size      = 256
  source_code_hash = data.archive_file.lambda.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.cars.name
    }
  }
}
