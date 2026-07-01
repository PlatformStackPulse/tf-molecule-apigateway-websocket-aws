# tf-molecule-apigateway-websocket-aws

[![Terraform Format](https://img.shields.io/badge/terraform-fmt-blue?logo=terraform)](https://github.com/PlatformStackPulse/tf-molecule-apigateway-websocket-aws/actions)
[![Terraform Validate](https://img.shields.io/badge/terraform-validate-blue?logo=terraform)](https://github.com/PlatformStackPulse/tf-molecule-apigateway-websocket-aws/actions)
[![TFLint](https://img.shields.io/badge/tflint-passing-brightgreen?logo=terraform)](https://github.com/PlatformStackPulse/tf-molecule-apigateway-websocket-aws/actions)
[![Terraform Test](https://img.shields.io/badge/tests-2%20passed-brightgreen?logo=terraform)](https://github.com/PlatformStackPulse/tf-molecule-apigateway-websocket-aws/actions)
[![Security Scan](https://img.shields.io/badge/trivy-passing-brightgreen?logo=aqua)](https://github.com/PlatformStackPulse/tf-molecule-apigateway-websocket-aws/actions)
[![Conventional Commits](https://img.shields.io/badge/commits-conventional-blue?logo=conventionalcommits)](https://conventionalcommits.org)
[![Documentation](https://img.shields.io/badge/docs-terraform--docs-blue?logo=readthedocs)](https://github.com/PlatformStackPulse/tf-molecule-apigateway-websocket-aws/actions)
[![License](https://img.shields.io/badge/license-MIT-blue?logo=opensourceinitiative)](LICENSE)

Terraform molecule that provisions an AWS API Gateway v2 **WebSocket** API — the API, an auto-deploying stage, and one Lambda-proxy integration + route + invoke permission per route key — with an optional regional custom domain and Route53 alias record.

## Features

- **WebSocket API** — `aws_apigatewayv2_api` with `protocol_type = "WEBSOCKET"` and route selection on `$request.body.action`.
- **Auto-deploying stage** — `aws_apigatewayv2_stage` with `auto_deploy = true` and default throttling (burst 100 / rate 50).
- **Route fan-out** — one `AWS_PROXY` integration, one route, and one `lambda:InvokeFunction` permission per entry in `var.routes` (e.g. `$connect`, `$disconnect`, `$default`, and custom actions).
- **Scoped invoke permission** — each Lambda permission is scoped to the API's `execution_arn/*/*`.
- **Optional custom domain** — regional `aws_apigatewayv2_domain_name` + API mapping, created only when `custom_domain_name` is set (`TLS_1_2`).
- **Optional DNS** — Route53 A/alias record, created only when both `custom_domain_name` and `zone_id` are supplied.

## Usage

```hcl
module "websocket_api" {
  source = "git::https://github.com/PlatformStackPulse/tf-molecule-apigateway-websocket-aws.git?ref=v1.0.0"

  api_name   = "eg-prod-chat-ws"
  stage_name = "prod"

  routes = {
    "$connect"    = aws_lambda_function.connect.arn
    "$disconnect" = aws_lambda_function.disconnect.arn
    "$default"    = aws_lambda_function.default.arn
    "sendMessage" = aws_lambda_function.send_message.arn
  }

  # Optional custom domain + DNS
  custom_domain_name = "ws.example.com"
  certificate_arn    = aws_acm_certificate.ws.arn
  zone_id            = data.aws_route53_zone.this.zone_id

  tags = {
    Project = "chat"
    Owner   = "platform-engineering"
  }
}
```

**Required inputs:** `api_name`, `stage_name`, `routes`.
**Optional inputs:** `custom_domain_name`, `certificate_arn`, `zone_id`, `tags`.

Connect clients to the WebSocket URL exposed by the `endpoint` output.

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [aws_apigatewayv2_api.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api) | resource |
| [aws_apigatewayv2_api_mapping.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api_mapping) | resource |
| [aws_apigatewayv2_domain_name.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_domain_name) | resource |
| [aws_apigatewayv2_integration.routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_integration) | resource |
| [aws_apigatewayv2_route.routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_route) | resource |
| [aws_apigatewayv2_stage.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_stage) | resource |
| [aws_lambda_permission.routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_route53_record.ws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_name"></a> [api\_name](#input\_api\_name) | Name of the WebSocket API | `string` | n/a | yes |
| <a name="input_stage_name"></a> [stage\_name](#input\_stage\_name) | Deployment stage name | `string` | n/a | yes |
| <a name="input_routes"></a> [routes](#input\_routes) | Map of route key to Lambda function ARN (e.g. {"$connect" = "arn:aws:lambda:..."}) | `map(string)` | n/a | yes |
| <a name="input_custom_domain_name"></a> [custom\_domain\_name](#input\_custom\_domain\_name) | Custom domain name for the WebSocket API (optional) | `string` | `null` | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | ACM certificate ARN for the custom domain | `string` | `null` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Route53 hosted zone ID for DNS record | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the API, stage, and custom domain | `map(string)` | `{}` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_id"></a> [api\_id](#output\_api\_id) | The ID of the WebSocket API |
| <a name="output_api_endpoint"></a> [api\_endpoint](#output\_api\_endpoint) | The WebSocket API endpoint URL |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | The full WebSocket connection endpoint (with stage) |
| <a name="output_execution_arn"></a> [execution\_arn](#output\_execution\_arn) | The execution ARN of the WebSocket API |
<!-- END_TF_DOCS -->

## Tests

Native `terraform test` with a mock AWS provider — no AWS credentials required.

```bash
terraform init -backend=false
terraform test -test-directory=tests/unit            # unit tests (mock provider)
# or
make test-unit
```

- `tests/unit/main_test.tftest.hcl` — mock-provider plan tests asserting the API/stage
  configuration, per-route fan-out counts (`routes` → integrations/routes/permissions),
  and the conditional custom-domain / Route53 resource creation. Assertions target only
  plan-known values (input pass-throughs and `length(...)` counts), never mock-unknown
  computed ARNs/IDs.
- `tests/integration/main_test.tftest.hcl` — real-AWS apply test
  (`terraform test -test-directory=tests/integration`, requires AWS credentials).

## License

[MIT](LICENSE)
