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

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to all resources"
}
