provider "aws" {
  region = var.AWS_REGION
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
  token = var.AWS_SESSION_TOKEN

  assume_role {
    role_arn    = var.AWS_ROLE_ARN
  }

}


