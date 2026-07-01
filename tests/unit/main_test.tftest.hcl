# Unit Tests — tf-molecule-apigateway-websocket-aws
#
# These tests use a mock AWS provider — no real AWS calls are made.
# Run with:        terraform test -test-directory=tests/unit
# Run verbose:     terraform test -test-directory=tests/unit -verbose
# Run specific:    terraform test -test-directory=tests/unit -run "creates_when_enabled"
#
# NOTE: Under a mock provider, computed attributes (api id, execution_arn,
# api_endpoint) are UNKNOWN at plan time, so assertions target only
# plan-KNOWN values: input pass-throughs (route_key, stage name) and
# conditional resource counts (length(...)).

mock_provider "aws" {}

variables {
  api_name   = "eg-test-thing"
  stage_name = "test"
  routes = {
    "$connect"    = "arn:aws:lambda:us-east-1:123456789012:function:eg-test-thing-connect"
    "$disconnect" = "arn:aws:lambda:us-east-1:123456789012:function:eg-test-thing-disconnect"
    "$default"    = "arn:aws:lambda:us-east-1:123456789012:function:eg-test-thing-default"
  }
  tags = {
    Namespace = "eg"
    Stage     = "test"
    Name      = "thing"
  }
}

# ---------------------------------------------------------------------------
# Test: module wires the WebSocket API, one route + integration + permission
# per entry in var.routes, and creates NO custom-domain resources by default.
# ---------------------------------------------------------------------------
run "creates_when_enabled" {
  command = plan

  assert {
    condition     = aws_apigatewayv2_api.this.name == "eg-test-thing"
    error_message = "WebSocket API name must equal the api_name input."
  }

  assert {
    condition     = aws_apigatewayv2_api.this.protocol_type == "WEBSOCKET"
    error_message = "API protocol_type must be WEBSOCKET."
  }

  assert {
    condition     = aws_apigatewayv2_stage.this.name == "test"
    error_message = "Stage name must equal the stage_name input."
  }

  assert {
    condition     = length(aws_apigatewayv2_route.routes) == 3
    error_message = "Expected one route per entry in var.routes (3)."
  }

  assert {
    condition     = length(aws_apigatewayv2_integration.routes) == 3
    error_message = "Expected one integration per entry in var.routes (3)."
  }

  assert {
    condition     = length(aws_lambda_permission.routes) == 3
    error_message = "Expected one Lambda permission per entry in var.routes (3)."
  }

  assert {
    condition     = aws_apigatewayv2_route.routes["$connect"].route_key == "$connect"
    error_message = "The $connect route_key must be passed through from var.routes."
  }

  assert {
    condition     = length(aws_apigatewayv2_domain_name.this) == 0
    error_message = "No custom-domain resource should be created when custom_domain_name is null."
  }

  assert {
    condition     = length(aws_route53_record.ws) == 0
    error_message = "No Route53 record should be created when custom_domain_name is null."
  }
}

# ---------------------------------------------------------------------------
# Test: setting custom_domain_name creates the domain + api mapping, and the
# Route53 record only when a zone_id is also supplied.
# ---------------------------------------------------------------------------
run "custom_domain_creates_domain_and_dns" {
  command = plan

  variables {
    custom_domain_name = "ws.example.com"
    certificate_arn    = "arn:aws:acm:us-east-1:123456789012:certificate/11111111-2222-3333-4444-555555555555"
    zone_id            = "Z0123456789ABCDEFGHIJ"
  }

  assert {
    condition     = length(aws_apigatewayv2_domain_name.this) == 1
    error_message = "A custom-domain resource should be created when custom_domain_name is set."
  }

  assert {
    condition     = length(aws_apigatewayv2_api_mapping.this) == 1
    error_message = "An API mapping should be created when custom_domain_name is set."
  }

  assert {
    condition     = length(aws_route53_record.ws) == 1
    error_message = "A Route53 record should be created when both custom_domain_name and zone_id are set."
  }

  assert {
    condition     = aws_apigatewayv2_domain_name.this[0].domain_name == "ws.example.com"
    error_message = "Custom domain_name must equal the custom_domain_name input."
  }
}
