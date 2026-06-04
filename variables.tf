# -----------------------------------------------------------------------------
# Module-Specific Variables
# -----------------------------------------------------------------------------

variable "api_name" {
  type        = string
  description = "Name of the WebSocket API"
}

variable "stage_name" {
  type        = string
  description = "Deployment stage name"
}

variable "routes" {
  type        = map(string)
  description = "Map of route key to Lambda function ARN (e.g. {\"$connect\" = \"arn:aws:lambda:...\"})"
}

variable "custom_domain_name" {
  description = "Custom domain name for the WebSocket API (optional)"
  type        = string
  default     = null
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the custom domain"
  type        = string
  default     = null
}

variable "zone_id" {
  description = "Route53 hosted zone ID for DNS record"
  type        = string
  default     = null
}
