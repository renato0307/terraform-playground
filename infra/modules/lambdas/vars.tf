variable "aws_region" {
  default = "eu-west-1"
}

variable "lambda_log_level" {
  description = "Log level for the Lambda Python runtime."
  default = "DEBUG"
}

variable "lambda_relative_path" {}

variable "lambda_name" {}

variable "lambda_friendly_name" {}

variable "lambda_description" {
  default = ""
}

variable "lambda_handler" {
  default = "lambda.handler"
}

variable "lambda_runtime" {
  default = "python3.8"
}

variable "lambda_memory" {
  default = 128
}

variable "lambda_timeout" {
  default = 30
}