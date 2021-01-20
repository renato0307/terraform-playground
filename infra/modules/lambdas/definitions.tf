
# Define a local variable for the Lambda function
# source code path in order to avoid repetitions.
locals {
  # Relative paths change if this configuration is
  # included as a module from Terragrunt.
  lambda_src_path = "${path.module}/${var.lambda_relative_path}"
}

# Compute the source code hash, only taking into
# consideration the actual application code files
# and the dependencies list.
resource "random_uuid" "lambda_src_hash" {
  keepers = {
    for filename in setunion(
      fileset(local.lambda_src_path, "*.py"),
      fileset(local.lambda_src_path, "**/*.py")
    ):
    filename => filemd5("${local.lambda_src_path}/${filename}")
  }
}

resource "random_uuid" "lambda_layer_src_hash" {
  keepers = {
    for filename in setunion(
      fileset(local.lambda_src_path, "requirements.txt"),
    ):
    filename => filemd5("${local.lambda_src_path}/${filename}")
  }
}

# Automatically install dependencies to be packaged
# with the Lambda function as required by AWS Lambda:
# https://docs.aws.amazon.com/lambda/latest/dg/python-package.html#python-package-dependencies
resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = "rm -rf ${path.module}/.tmp/${var.lambda_name} && mkdir -p ${path.module}/.tmp/${var.lambda_name} && pip install -r ${local.lambda_src_path}/requirements.txt -t ${path.module}/.tmp/${var.lambda_name}/ --upgrade"
  }

  # Only re-run this if the dependencies or their versions
  # have changed since the last deployment with Terraform
  triggers = {
    #dependencies_versions = filemd5("${local.lambda_src_path}/requirements.txt")
    source_code_hash = random_uuid.lambda_layer_src_hash.result # This is a suitable option too
  }
}

# Create an archive form the Lambda source code,
# filtering out unneeded files.
data "archive_file" "lambda_source_package" {
  type        = "zip"
  source_dir  = local.lambda_src_path
  output_path = "${path.module}/.tmp/${random_uuid.lambda_src_hash.result}.zip"

  excludes    = [
    "__pycache__",
    "core/__pycache__",
    "tests"
  ]

  # This is necessary, since archive_file is now a
  # `data` source and not a `resource` anymore.
  # Use `depends_on` to wait for the "install dependencies"
  # task to be completed.
  # depends_on = [null_resource.install_dependencies, null_resource.copy_lambda_code]
}

data "archive_file" "lambda_layer_source_package" {
  type        = "zip"
  source_dir  = "${path.module}/.tmp/${var.lambda_name}/"
  output_path = "${path.module}/.tmp/${random_uuid.lambda_layer_src_hash.result}.zip"

  excludes    = [
    "__pycache__",
    "core/__pycache__",
    "tests"
  ]

  # This is necessary, since archive_file is now a
  # `data` source and not a `resource` anymore.
  # Use `depends_on` to wait for the "install dependencies"
  # task to be completed.
  depends_on = [null_resource.install_dependencies]
}

# Create an IAM execution role for the Lambda function.
resource "aws_iam_role" "execution_role" {
  # IAM Roles are "global" resources. Lambda functions aren't.
  # In order to deploy the Lambda function in multiple regions
  # within the same account, separate Roles must be created.
  # The same Role could be shared across different Lambda functions,
  # but it's just not convenient to do so in Terraform.
  name = "lambda-execution-role-${var.lambda_name}-${var.aws_region}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    provisioner = "terraform"
  }
}

# Attach a IAM policy to the execution role to allow
# the Lambda to stream logs to Cloudwatch Logs.
resource "aws_iam_role_policy" "log_writer" {
  name = "lambda-log-writer-${var.lambda_name}"
  role = aws_iam_role.execution_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Deploy the Lambda layer to AWS
resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = data.archive_file.lambda_layer_source_package.output_path
  layer_name = "${var.lambda_name}_layer"
  compatible_runtimes = [var.lambda_runtime]
  source_code_hash = data.archive_file.lambda_layer_source_package.output_base64sha256
}

# Deploy the Lambda function to AWS
resource "aws_lambda_function" "lambda_function" {
  function_name = var.lambda_friendly_name
  description = var.lambda_description
  role = aws_iam_role.execution_role.arn
  filename = data.archive_file.lambda_source_package.output_path
  runtime = var.lambda_runtime
  handler = var.lambda_handler
  memory_size = var.lambda_memory
  timeout = var.lambda_timeout
  layers = [aws_lambda_layer_version.lambda_layer.arn]

  source_code_hash = data.archive_file.lambda_source_package.output_base64sha256

  tags = {
    provisioner = "terraform"
  }

  environment {
    variables = {
      LOG_LEVEL = var.lambda_log_level
    }
  }

  lifecycle {
    # Terraform will any ignore changes to the
    # environment variables after the first deploy.
    ignore_changes = [environment]
  }
}

# The Lambda function would create this Log Group automatically
# at runtime if provided with the correct IAM policy, but
# we explicitly create it to set an expiration date to the streams.
resource "aws_cloudwatch_log_group" "lambda_function" {
  name = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"
  retention_in_days = 30
}

output "lambda_function_invoke_arn" {
  description = "Lambda function invoke ARN"
  value       = aws_lambda_function.lambda_function.invoke_arn
}