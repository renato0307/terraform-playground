variable "AWS_REGION" {
  default = "eu-west-1"
}

variable AWS_ACCESS_KEY_ID {}
variable AWS_SECRET_ACCESS_KEY {}
variable AWS_SESSION_TOKEN {}
variable AWS_ROLE_ARN {}

variable "lambda_log_level" {
  description = "Log level for the Lambda Python runtime."
  default = "DEBUG"
}

variable "lambda_relative_path" {
  description = "DO NOT CHANGE. This will be overridden by Terragrunt when needed."
  default = "/../../"
}