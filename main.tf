# Terraform configuration for simple Lambda + API Gateway

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS provider
provider "aws" {
  region = var.aws_region
}

# ============================================================
# IAM Role for Lambda Execution
# ============================================================

resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach AWS managed policy for basic Lambda execution
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ============================================================
# Lambda Function
# ============================================================

resource "aws_lambda_function" "this" {
  filename         = "lambda_function.zip"
  function_name    = var.project_name
  description      = "Simple Lambda function that returns 200"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_function.handler"
  source_code_hash = filebase64sha256("lambda_function.zip")
  
  runtime = "python3.12"
  timeout = 30
  memory_size = 128

  # Environment variables (empty for now)
  environment {
    variables = {}
  }
}

# ============================================================
# API Gateway HTTP API
# ============================================================

resource "aws_apigatewayv2_api" "this" {
  name          = var.project_name
  protocol_type = "HTTP"
  
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET"]
    allow_headers = ["*"]
  }
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id = aws_apigatewayv2_api.this.id

  integration_type = "AWS_PROXY"
  integration_method = "POST"
  payload_format_version = "2.0"
  
  connection_type = "INTERNET"
  integration_uri = aws_lambda_function.this.invoke_arn
}

resource "aws_apigatewayv2_route" "this" {
  api_id = aws_apigatewayv2_api.this.id
  route_key = "GET /"
  
  target = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# ============================================================
# Lambda Permission for API Gateway
# ============================================================

resource "aws_lambda_permission" "api_gateway" {
  statement_id = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}

# ============================================================
# API Gateway Stage
# ============================================================

resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.this.id
  name   = "$default"
  
  auto_deploy = true
  
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    # Replaced $context.endpoint with $context.path
    format = jsonencode({
      requestId      = "$context.requestId"
      sourceIp       = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
      latency        = "$context.responseLatency"
      path           = "$context.path" 
    })
  }
}

# ============================================================
# CloudWatch Log Group for API Gateway
# ============================================================

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.project_name}"
  retention_in_days = 1
}

# ============================================================
# Output the API endpoint
# ============================================================
/*
output "api_endpoint" {
  description = "The HTTP API endpoint URL"
  value       = aws_apigatewayv2_api.this.api_endpoint
  sensitive  = false
}

output "lambda_function_name" {
  description = "The Lambda function name"
  value       = aws_lambda_function.this.function_name
  sensitive   = false
}

output "lambda_function_arn" {
  description = "The Lambda function ARN"
  value       = aws_lambda_function.this.arn
  sensitive   = false
}*/