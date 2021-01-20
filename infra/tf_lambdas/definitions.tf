module "lambdas" {
  source = "../modules/lambdas/"
  lambda_relative_path = "../../../"
  lambda_name = "sample_lambda"
}