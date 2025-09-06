# STEP 3: After creating Lambda manually, uncomment this import block
# import {
#   to = aws_lambda_function.this_lambda
#   id = "manually-created-lambda"
# }

# Here we are defining the Lambda function's deployment package.
data "archive_file" "this_lambda" {
  type        = "zip"
  source_file = "${path.root}/build/index.mjs"
  output_path = "${path.root}/lambda.zip"
}

# Here we are defining the Lambda function. This function will be created using the deployment package defined above.
# The resource mentioned below is not manually written, above we have an import block.
# We run that and take the output in a file named generated.tf.
#Then we copy the resource block from that file to here. And then we delete that file. 

resource "aws_lambda_function" "this_lambda" {
  description                        = "A starter AWS Lambda function."
  filename                           = "lambda.zip"
  function_name                      = "manually-created-lambda"
  handler                            = "index.handler"
  reserved_concurrent_executions     = -1
  role                               = aws_iam_role.lambda_execution_role.arn
  runtime                            = "nodejs22.x"

  source_code_hash = data.archive_file.this_lambda.output_base64sha256
  tags = {
    "lambda-console:blueprint" = "hello-world"
  }

# Logging configuration. This configuration defines how logs are handled for the Lambda function.
  logging_config {
    log_format = "Text"
    log_group  = aws_cloudwatch_log_group.lambda.name
  }
}

# Here we are defining a Lambda function URL. This URL allows us to invoke the Lambda function via HTTP.
resource "aws_lambda_function_url" "this_lambda" {
  function_name      = aws_lambda_function.this_lambda.function_name
  authorization_type = "NONE"
}