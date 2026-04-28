# Output definitions

output "api_endpoint" {
  description = "The HTTP API endpoint URL"
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "lambda_function_name" {
  description = "The Lambda function name"
  value       = aws_lambda_function.this.function_name
}

output "lambda_function_arn" {
  description = "The Lambda function ARN"
  value       = aws_lambda_function.this.arn
}