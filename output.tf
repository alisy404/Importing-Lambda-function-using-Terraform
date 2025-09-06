# This file outputs the URL of the Lambda function.
output "lambda_url" {
    value = aws_lambda_function_url.this_lambda.function_url
}