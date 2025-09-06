# STEP 3: After creating Lambda manually, uncomment and update these import blocks with actual resource IDs

# import {
#   to = aws_iam_role.lambda_execution_role
#   id = "REPLACE_WITH_ACTUAL_ROLE_NAME"  # e.g., "manually-created-lambda-role-abc123"
# }

# import {
#   to = aws_iam_policy.lambda_execution  
#   id = "REPLACE_WITH_ACTUAL_POLICY_ARN"  # e.g., "arn:aws:iam::123456789012:policy/service-role/AWSLambdaBasicExecutionRole-xyz"
# }

# import {
#   to = aws_iam_role_policy_attachment.lambda_execution
#   id = "ROLE_NAME/POLICY_ARN"  # e.g., "manually-created-lambda-role-abc123/arn:aws:iam::123456789012:policy/service-role/AWSLambdaBasicExecutionRole-xyz"
# }


data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#Here we are defining the policy document that allows the Lambda function to assume the execution role.
data "aws_iam_policy_document" "lambda_execution" {
  statement {
    effect    = "Allow"
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]

    actions = ["logs:CreateLogGroup"]
  }

  statement {
    effect    = "Allow"
    resources = ["${aws_cloudwatch_log_group.lambda.arn}:*"]

    actions = ["logs:CreateLogStream", "logs:PutLogEvents"]
  }
}

# Here we are defining the Lambda execution policy. This policy allows the Lambda function to assume the execution role and perform actions on AWS resources.
resource "aws_iam_policy" "lambda_execution" {
  name   = "AWSLambdaBasicExecutionRole-772fef57-9ace-49ed-b636-7c1eb8b2f64f"
  path   = "/service-role/"
  policy = data.aws_iam_policy_document.lambda_execution.json
}


# Here we are defining the Lambda execution role. This role allows the Lambda function to assume the execution role and perform actions on AWS resources.
resource "aws_iam_role" "lambda_execution_role" {
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  path = "/service-role/"
  name = "manually-created-lambda-role-1mxmv22n"

}

# Here we are attaching the Lambda execution policy to the Lambda execution role. This is used in replacement of manged_policy_arns mentioned in the above code block because the mangaed_policy_arn is depricated.
resource "aws_iam_role_policy_attachment" "lambda_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_execution.arn
}

