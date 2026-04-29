# Simple Lambda with Terraform

A minimal AWS Lambda function that responds to HTTP GET requests with a 200 status code. This project is designed to help you understand the core components of a basic serverless architecture.

## Architecture Overview

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   Client        │────▶│  API Gateway     │────▶│  Lambda         │
│   (curl/browser)│     │  HTTP API        │     │  Function       │
└─────────────────┘     └──────────────────┘     └─────────────────┘
```

## Components

### 1. Lambda Function (`lambda_function.py`)
- **Purpose**: The actual compute logic
- **Runtime**: Python 3.12
- **Handler**: `lambda_function.handler`
- **Output**: Returns `{"statusCode": 200, "body": "OK"}`

### 2. API Gateway HTTP API (`main.tf`)
- **Purpose**: HTTP trigger for the Lambda
- **Protocol**: HTTP (v2) - simpler than REST API
- **Route**: `GET /`
- **Integration**: AWS_PROXY (Lambda handles the full response)

### 3. IAM Role (`main.tf`)
- **Purpose**: Grants permissions to Lambda
- **Policy**: `AWSLambdaBasicExecutionRole` - allows writing CloudWatch logs
- **Trust**: Lambda service can assume this role

### 4. CloudWatch Log Group
- **Purpose**: Stores API Gateway access logs
- **Retention**: 1 day (for learning purposes)

## Files

| File | Description |
|------|-------------|
| `lambda_function.py` | Python Lambda handler |
| `main.tf` | Terraform infrastructure code |
| `variables.tf` | Terraform variables |
| `outputs.tf` | Terraform outputs |
| `deploy.sh` | Deployment script |

## Prerequisites

- [ ] AWS account
- [ ] AWS CLI configured (`aws configure`)
- [ ] Terraform installed (>= 1.0)

## Quick Start

### 1. Clone and navigate
```bash
cd simple-lambda
```

### 2. Deploy
```bash
chmod +x deploy.sh
./deploy.sh
```

### 3. Test
```bash
curl $(terraform output -raw api_endpoint)
# Expected: {"message": "OK"}
```

## Cleanup

To destroy all created resources:
```bash
terraform destroy
```

## Learning Points

### What each component does:

1. **Lambda Function**: Serverless compute - you only pay when invoked
2. **API Gateway**: HTTP entry point - handles routing, auth, CORS
3. **IAM Role**: Security - defines what the Lambda can do
4. **Terraform**: Infrastructure as Code - reproducible deployments

### Key Terraform concepts:

- `resource`: Creates an AWS resource
- `variable`: Parameterizable values
- `output`: Exposes values after deployment
- `provider`: Defines which cloud to use

## Next Steps

Try these modifications to learn more:

1. **Add path parameter**: Modify route to `GET /hello/{name}`
2. **Add environment variable**: Pass config to Lambda
3. **Add CloudWatch alarm**: Monitor invocation errors
4. **Add custom domain**: Use Route 53 for custom URL
#This is a test comment before the test comment