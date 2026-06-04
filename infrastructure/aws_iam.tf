# ============================================================================
# IAM - Lambda Execution Role
# ============================================================================

resource "aws_iam_role" "lambda" {
  name = "${var.project_prefix}-server-${var.environment}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "dynamodb-access"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["dynamodb:Scan", "dynamodb:Query", "dynamodb:GetItem"]
      Resource = [
        aws_dynamodb_table.cars.arn,
        "${aws_dynamodb_table.cars.arn}/index/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
