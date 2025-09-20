# Check Point Home Assignment

Solution for the Check Point home assignment implementing a file upload system.

## Architecture Overview

This project implements a file upload system using AWS services and containerized microservices.
The system consists of two main services and comprehensive AWS infrastructure managed through Terraform.

### Key Components

1. **Microservices**:

   - **Token Validator Service**: Validates upload tokens - ECS
   - **Uploader Service**: Handles file upload operations - Lambda

2. **AWS Infrastructure**:
   - ECS Fargate for container orchestration
   - Application Load Balancer (ALB) for traffic distribution
   - S3 for file storage
   - SQS for message queuing
   - Lambda for serverless processing
   - Route53 for DNS management - not functioning currently on namecheap side

## Project Structure

```
application/
├── token-validator-service/    # Token validation microservice
│   ├── app.py
│   └── Dockerfile
└── uploader-service/          # File upload microservice
    ├── app.py
    └── Dockerfile

terraform/                     # Infrastructure as Code
├── main.tf                   # Main Terraform configuration
├── variables.tf              # Variable definitions
├── outputs.tf                # Output configurations
└── modules/                  # Terraform modules
    ├── acm_cert/            # SSL/TLS certificate management
    ├── alb/                 # Load balancer configuration
    ├── ecr/                 # Container registry
    ├── ecs_fargate/        # Container orchestration
    ├── lambda_sqs_s3/      # Serverless processing
    ├── route53/            # DNS configuration - can be ignored
    ├── s3/                 # Object storage
    ├── security_group/     # Network security
    ├── sqs/                # Message queue
    └── vpc/                # Network configuration
```

## Getting Started

## Infrastructure Details

### Networking

- VPC configuration for secure network isolation
- Security groups for fine-grained access control
- Route53 for DNS management - not functioning

### Compute

- ECS Fargate for running containerized services
- Lambda functions for event-driven processing

### Storage and Messaging

- S3 buckets for secure file storage
- SQS queues for reliable message processing

### Security

- ACM certificates for SSL/TLS
- IAM roles and policies for secure access
- Security groups for network isolation
