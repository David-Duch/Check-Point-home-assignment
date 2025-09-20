# Check Point Home Assignment

Solution for the Check Point home assignment implementing a file upload system.

## Architecture Overview

This project implements a file upload system using AWS services and containerized microservices.
The system consists of two main services and comprehensive AWS infrastructure managed through Terraform.

### Tech Stack:
AWS: ECS (Fargate), Lambda, SQS (FIFO), EventBridge, ALB, VPC.

IaC: Terraform (reusable modules, multiple workspaces).

CI/CD: GitHub Actions (build, tag, push, deploy Docker images).

App: Python microservices, Dockerized, SSM-managed secrets.

### Key Components

1. **Microservices**:
   - **Token Validator Service**: Validates upload tokens - ECS
   - **Uploader Service**: Handles file upload operations - Lambda

> [!NOTE]
> I decided to use both ECS and Lambda for a variety of reasons. ECS fits well for a polling microservice.
> While Lambda enables an event-driven architecture, allowing us in the future to switch from a fixed polling rate to triggering on actual events.

2. **AWS Infrastructure**:
   - ECS Fargate for container orchestration
   - Application Load Balancer (ALB) for traffic distribution
   - S3 for file storage
   - SQS for message queuing
   - Lambda for serverless processing
   - Route53 for DNS management - not functioning currently managedon namecheap side  - **https://alfee.site**

## Project Structure

```
application/
├── token-validator-service/     # Token validation microservice
│   ├── app.py
│   └── Dockerfile
└── uploader-service/            # File upload microservice
    ├── app.py
    └── Dockerfile

terraform/                       # Infrastructure as Code
├── main.tf                      # Main Terraform configuration
├── variables.tf                 # Variable definitions
├── outputs.tf                   # Output configurations
└── modules/                     # Terraform modules
    ├── acm_cert/                # SSL/TLS certificate management
    ├── alb/                     # Load balancer configuration
    ├── ecr/                     # Container registry
    ├── ecs_fargate/             # Container orchestration
    ├── lambda_sqs_s3/           # Serverless processing
    ├── route53/                 # DNS configuration - can be ignored
    ├── s3/                      # Object storage
    ├── security_group/          # Network security
    ├── sqs/                     # Message queue
    └── vpc/                     # Network configuration
```

## Getting Started
The Terraform configuration incorporates the workspace (environment) into each resource name, allowing generic modules to be reused across multiple environments.
At the moment, only one main environment exists: prod.
After cloning the repository, authenticate with AWS:
```
aws configure sso
```
Navigate to the Terraform folder, initialize the project, and select the desired workspace:
```
cd terraform
terraform init
terraform workspace select prod
```
You can now apply the full Terraform module stack. It’s often helpful to run a plan first to review the changes:
```
terraform apply 
```
In our case we expect to see:
No changes. Your infrastructure matches the configuration.

To recreate the full application infrastructure in a new workspace (for example: dev), choose a short workspace name. Some AWS services have name length limits (typically 32 characters), so shorter names help avoid issues.
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
> Occasionally, Terraform may encounter an error due to resource dependency order. Running terraform apply a second time usually resolves it.
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
## Service Architecture

<img width="651" height="428" alt="diagram" src="https://github.com/user-attachments/assets/0b415db0-33ac-4b12-b96d-e897d8e5043e" />



## GitHub Actions 
There are 4 main workflows: 

Build Token Validor Service - builds and pushes the docker to the relevant ECR with the tag: token-**run-number** (for example token-6). 

Build Uploader Service - builds and pushes the docker to the relevant ECR with the tag: upload-**run-number** (for example upload-5). 

Deploy Token Validator Service - Inputs:  
```
Image tag: token-6
Environment: prod
```
This will tag the token-6 image with prod and will trigger ECS deployment with new image.

Deploy Uploader Service - Inputs:
```
Image tag: upload-5
Environment: prod
```
This will tag the upload-5 image with prod and will trigger a Lambda deployment with new image.

## API Calls
> [!NOTE]
> The service supports HTTPS only and has a valid certificate.

These calls are importable to postman by copy paste.
Health check:
```
curl --location 'https://alfee.site/health'
```
Expected result 200 OK. 

Valid call, should send a message to the validating service (token is correct and formatter well), thus it will be sent to the SQS and pulled by the Lambda in the next 5 minute cycle and uploaded to S3: 
```
curl --location 'https://alfee.site/message' \
--header 'Content-Type: application/json' \
--data '{"data":{"email_subject":"Testing!","email_sender":"David Duch","email_timestream":"12345","email_content":"!!!"},"token":"$DJISA<$#45ex3RtYr"}'
```
Expected result:
```
{
    "status": "accepted"
}
```

## Future Improvements
1. CloudFront + WAF – Enhance security and monitoring for URLs.
2. Route53 migration – Move DNS from Namecheap to an AWS hosted zone for better management and state tracking.
3. Security group enhancements – Refine rules for improved security.
4. ECS autoscaling – Enable automatic scaling for the microservice.
5. Testing – Implement unit and integration tests.
6. Monitoring – Add observability for service health and metrics.
7. GitHub Actions - improve deploy pipeline with a dropdown list of ECR images. 
