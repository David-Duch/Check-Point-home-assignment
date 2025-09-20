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
The terraform configuration uses the workspace (environment) in the resource name thus reusing genric modules to create multiple environemtns easily. 
Currently there is one main envrironment which is: **prod** 
After cloning the repo.
Authenticate with AWS:
```
aws configure sso
```
Move to terraform folder, init and select workspace 
```
cd terraform
terraform init
terraform workspace select prod
```
Now you can apply the entire module stack (planning before hand to see changes can be helpful).
```
terraform apply 
```
In our case we expect to see:
No changes. Your infrastructure matches the configuration.

To recreate the full application infrastructure in a new workspace: 
dev workspace but any short name will match (aws has multiple services where longer names 32 chars and above can cause issues). 
```
cd terraform
terraform workspace new dev 
terraform init
terraform apply
```
We expect to see:
**Plan: 48 to add, 0 to change, 0 to destroy.
**
> [!CAUTION]
> Occasionally we run into an unresolved error due to applying order, applying twice usually solves it. 
```
╷
│ Error: Invalid count argument
│
│   on modules\alb\main.tf line 31, in resource "aws_lb_listener_rule" "message":
│   31:   count = var.messages_target_group_arn == null ? 0 : 1
│
│ to first apply only the resources that the count depends on.
╷
│ Error: Invalid for_each argument
│
│   on modules\security_group\main.tf line 23, in resource "aws_security_group_rule" "ingres
│   23: for_each = {
│   24:   for i, r in var.ingress_rules : i => r
│   25:   if r.source_sg_id != null && r.source_sg_id != ""
│   26: }
│     ├────────────────
│     │ var.ingress_rules is list of object with 2 elements
│
│ The "for_each" map includes keys derived from resource attributes that cannot be determine
│ this resource.
│
│ When working with unknown values in for_each, it's better to define the map keys staticall
│
│ Alternatively, you could use the -target planning option to first apply only the resources
```
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
