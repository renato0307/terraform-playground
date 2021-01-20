variable "aws_region" {
  default = "eu-west-1"
}

variable "lambda_log_level" {
  description = "Log level for the Lambda Python runtime."
  default = "DEBUG"
}

variable "lambda_relative_path" {}

variable "lambda_name" {}