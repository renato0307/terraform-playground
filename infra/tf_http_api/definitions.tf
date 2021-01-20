module "http_api" {
  source = "../modules/http_api/"
  lambda_relative_path = "../../../sample_lambda_http_api"
  lambda_name = "sample_lambda_http_api"
  lambda_friendly_name = "sample_lambda_http_api"
}