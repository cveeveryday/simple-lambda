#!/bin/bash
# Deployment script for simple Lambda function

set -e

echo "=== Simple Lambda Deployment Script ==="
echo ""

# Check if AWS credentials are configured
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "Error: AWS credentials not configured"
    echo "Please run 'aws configure' or set AWS credentials"
    exit 1
fi

echo "Step 1: Zipping Lambda function..."
cd "$(dirname "$0")"
zip -r lambda_function.zip lambda_function.py
echo "✓ Lambda function zipped"
echo ""

echo "Step 2: Initializing Terraform..."
terraform init
echo "✓ Terraform initialized"
echo ""

echo "Step 3: Planning deployment..."
terraform plan
echo ""

echo "Step 4: Applying Terraform configuration..."
read -p "Do you want to proceed with deployment? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 1
fi

terraform apply
echo ""

echo "=== Deployment Complete ==="
echo ""
echo "API Endpoint:"
terraform output -raw api_endpoint
echo ""
echo "Test the endpoint with:"
echo "  curl \$(terraform output -raw api_endpoint)"