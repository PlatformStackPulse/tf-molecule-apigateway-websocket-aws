output "api_id" {
  description = "The ID of the WebSocket API"
  value       = aws_apigatewayv2_api.this.id
}

output "api_endpoint" {
  description = "The WebSocket API endpoint URL"
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "endpoint" {
  description = "The full WebSocket connection endpoint (with stage)"
  value       = "${aws_apigatewayv2_api.this.api_endpoint}/${var.stage_name}"
}

output "execution_arn" {
  description = "The execution ARN of the WebSocket API"
  value       = aws_apigatewayv2_api.this.execution_arn
}
