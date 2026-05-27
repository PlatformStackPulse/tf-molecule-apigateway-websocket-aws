# =============================================================================
# API Gateway WebSocket Molecule
# Composes: WebSocket API + Stage + Routes + Lambda Integrations
# =============================================================================

resource "aws_apigatewayv2_api" "this" {
  name                       = var.api_name
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"

  tags = var.tags
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.stage_name
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 100
    throttling_rate_limit  = 50
  }

  tags = var.tags
}

resource "aws_apigatewayv2_integration" "routes" {
  for_each = var.routes

  api_id             = aws_apigatewayv2_api.this.id
  integration_type   = "AWS_PROXY"
  integration_uri    = each.value
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "routes" {
  for_each = var.routes

  api_id    = aws_apigatewayv2_api.this.id
  route_key = each.key
  target    = "integrations/${aws_apigatewayv2_integration.routes[each.key].id}"
}

resource "aws_lambda_permission" "routes" {
  for_each = var.routes

  statement_id  = "AllowWSInvoke-${replace(each.key, "$", "")}"
  action        = "lambda:InvokeFunction"
  function_name = each.value
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}
