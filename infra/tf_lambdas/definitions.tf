module "lambdas" {
  source = "../modules/lambdas/"
  lambda_relative_path = "../../../sample_lambda"
  lambda_name = "sample_lambda"
  lambda_friendly_name = "sample_lambda"
}

module "lambdas2" {
  source = "../modules/lambdas/"
  lambda_relative_path = "../../../sample_lambda"
  lambda_name = "sample_lambda2"
  lambda_friendly_name = "sample_lambda2"
}