# Terraform Lambda Import Project

## Project Description

This project demonstrates how to **import existing AWS resources** into Terraform management. Instead of creating resources with Terraform from scratch, this project shows the reverse process:

1. **Create AWS Lambda function manually** via AWS Console
2. **Import the existing resources** into Terraform state
3. **Manage the resources** using Terraform going forward

This is useful when you have existing AWS infrastructure that you want to bring under Terraform management.

## Resources Managed

- AWS Lambda Function (`manually-created-lambda`)
- IAM Role for Lambda execution
- IAM Policy for Lambda logging permissions
- IAM Role Policy Attachment
- CloudWatch Log Group for Lambda logs
- Lambda Function URL (public endpoint)

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform installed (>= 1.0)
- Node.js source file in `build/index.mjs`

## Step-by-Step Launch Instructions

### Step 1: Create Lambda Function Manually

1. **Go to AWS Lambda Console** in your browser
2. **Click "Create function"**
3. **Choose "Author from scratch"**
4. **Fill in these details:**
   - **Function name**: `manually-created-lambda`
   - **Runtime**: Node.js 22.x
   - **Handler**: `index.handler`
   - **Execution role**: "Create a new role with basic Lambda permissions"
5. **Click "Create function"**

### Step 2: Prepare Source Code

Create the Lambda source file:
```bash
mkdir -p build
cat > build/index.mjs << 'EOF'
export const handler = async (event) => {
    return {
        statusCode: 200,
        body: JSON.stringify({
            message: 'Hello from manually created Lambda!',
            timestamp: new Date().toISOString()
        })
    };
};
EOF
```

### Step 3: Get Resource Information

Run these commands to get the actual resource names created by AWS:

```bash
# Get Lambda function details
aws lambda get-function --function-name manually-created-lambda --query 'Configuration.FunctionName'

# Get IAM role name (look for the role created with your Lambda)
aws iam list-roles --query 'Roles[?contains(RoleName, `manually-created-lambda`)].RoleName' --output text

# Get the policy ARN attached to the role (replace ROLE_NAME with actual role name)
ROLE_NAME=$(aws iam list-roles --query 'Roles[?contains(RoleName, `manually-created-lambda`)].RoleName' --output text)
aws iam list-attached-role-policies --role-name $ROLE_NAME
```

### Step 4: Update Terraform Import Blocks

Update the import blocks in your Terraform files with the actual resource names:

#### Update `iam.tf`
Replace the placeholder values with actual ones:
```hcl
# Uncomment and update these import blocks
import {
  to = aws_iam_role.lambda_execution_role
  id = "manually-created-lambda-role-ACTUAL_SUFFIX"  # Use actual role name
}

import {
  to = aws_iam_policy.lambda_execution  
  id = "arn:aws:iam::YOUR_ACCOUNT:policy/service-role/AWSLambdaBasicExecutionRole-ACTUAL_SUFFIX"
}

import {
  to = aws_iam_role_policy_attachment.lambda_execution
  id = "ROLE_NAME/POLICY_ARN"  # Use actual role name and policy ARN
}
```

Also update the resource definitions to match the actual names.

#### Update `lambda.tf`
Uncomment the import block:
```hcl
import {
  to = aws_lambda_function.this_lambda
  id = "manually-created-lambda"
}
```

#### Update `cloudwatch.tf`
Uncomment the import block:
```hcl
import {
  to = aws_cloudwatch_log_group.lambda
  id = "/aws/lambda/manually-created-lambda"
}
```

### Step 5: Initialize and Import

```bash
# Initialize Terraform
terraform init

# Plan the import (this will show what will be imported)
terraform plan

# Apply to import resources into Terraform state
terraform apply
```

### Step 6: Verify Import Success

```bash
# Check what resources are now managed by Terraform
terraform state list

# Test the Lambda function URL (if created)
terraform output lambda_url
```

### Step 7: Test Terraform Management

```bash
# Test destroy to verify Terraform can manage the resources
terraform destroy

# Recreate everything using Terraform
terraform apply
```

## Project Structure

```
17-proj-import-lambda/
├── README.md              # This file
├── provider.tf            # AWS provider configuration
├── iam.tf                 # IAM role, policy, and attachment
├── lambda.tf              # Lambda function and function URL
├── cloudwatch.tf          # CloudWatch log group
├── output.tf              # Output values
├── module.tf              # Module configuration
├── build/
│   └── index.mjs         # Lambda source code
└── lambda.zip            # Generated deployment package
```

## Common Issues & Solutions

### Issue: "Cannot import non-existent remote object"
**Solution**: Make sure you created the Lambda function manually in AWS Console first.

### Issue: Role/Policy names don't match
**Solution**: Update the resource names in Terraform files to match the actual names created in AWS.

### Issue: Import blocks still commented
**Solution**: Uncomment the import blocks in `iam.tf`, `lambda.tf`, and `cloudwatch.tf` after updating them with actual resource IDs.

### Issue: Missing policy attachment
**Solution**: Make sure to import the `aws_iam_role_policy_attachment` resource that connects the policy to the role.

## Key Learning Points

1. **Import workflow**: Manual creation → Get resource IDs → Update Terraform → Import
2. **Dependency management**: Import role policy attachments to avoid deletion conflicts
3. **Resource matching**: Terraform resource definitions must match existing AWS resources exactly
4. **State management**: After import, Terraform manages the full lifecycle of resources

## Next Steps

After successfully importing, you can:
- Modify Lambda configuration through Terraform
- Add additional resources (API Gateway, DynamoDB, etc.)
- Implement CI/CD pipelines
- Add monitoring and alerting

## Cleanup

To remove all resources:
```bash
terraform destroy
```

This will delete the Lambda function, IAM role, policy, log group, and function URL.
