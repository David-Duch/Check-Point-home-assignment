terraform {
  required_version = ">= 1.13.0"

  backend "s3" {
    bucket = "terraform-state-checkpoint"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source               = "./modules/vpc"
  name                 = "checkpoint"
  cidr_block           = "10.10.0.0/16"

  public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnet_cidrs = ["10.10.3.0/24", "10.10.4.0/24"]

  availability_zones   = ["us-east-1a", "us-east-1b"]

  project              = "Checkpoint"
}

module "alb_sg" {
  source = "./modules/security_group"
  name   = "alb-sg"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port    = 443
      to_port      = 443
      protocol     = "tcp"
      cidr_blocks  = ["0.0.0.0/0"]
      source_sg_id = ""   
    }
  ]

  egress_rules = [
    {
      from_port         = 0
      to_port           = 0
      protocol          = "-1"
      cidr_blocks       = ["0.0.0.0/0"]
      destination_sg_id = ""  
    }
  ]
}

module "token_validator_sg" {
  source = "./modules/security_group"
  name   = "token-validator-sg"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port     = 443
      to_port       = 443
      protocol      = "tcp"
      cidr_blocks   = []
      source_sg_id  = module.alb_sg.sg_id
    }
  ]

  egress_rules = [
    {
      from_port         = 0
      to_port           = 0
      protocol          = "-1"
      cidr_blocks       = ["0.0.0.0/0"]
      destination_sg_id = ""
    }
  ]
}

module "alfee_acm_cert" {
  source      = "./modules/acm_cert"
  domain_name = "alfee.site"
  project     = "Checkpoint"
}

module "alb" {
  source          = "./modules/alb"
  name            = "alb"
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnet_ids
  alb_sg_id       = module.alb_sg.sg_id  
  certificate_arn = module.alfee_acm_cert.certificate_arn  
  messages_target_group_arn = module.token_validator_service.target_group_arn
  project         = "Checkpoint"
}

module "token_validator_ecr" {
  source     = "./modules/ecr"
  name       = "token-validator-service"
  account_id = var.account_id
}

module "uploader_ecr" {
  source     = "./modules/ecr"
  name       = "uploader-service"
  account_id = var.account_id
}

module "sqs_message_storage" {
  source     = "./modules/s3"
  name       = "sqs-message-storage-${terraform.workspace}-${var.account_id}"
  account_id = var.account_id
}

module "messages_queue" {
  source     = "./modules/sqs"
  name       = "messages-queue-${terraform.workspace}"
  account_id = var.account_id
}

module "uploader_lambda" {
  source = "./modules/lambda_sqs_s3"

  lambda_name         = "uploader-service"
  image_uri           = "315915553428.dkr.ecr.us-east-1.amazonaws.com/uploader-service:latest"
  s3_bucket           = module.sqs_message_storage.bucket_id
  s3_path             = "uploads/"
  schedule_expression = "rate(5 minutes)"
  project             = "Checkpoint"
  sqs_arn = module.messages_queue.sqs_arn
  sqs_url = module.messages_queue.sqs_url
}

module "token_validator_service" {
  source           = "./modules/ecs_fargate"
  aws_region       = "us-east-1"
  vpc_id          = module.vpc.vpc_id
  service_name     = "token-validator-service"
  project          = "Checkpoint"
  private_subnets  = module.vpc.private_subnet_ids
  security_groups  = [module.token_validator_sg.sg_id]
  image_url        = "315915553428.dkr.ecr.us-east-1.amazonaws.com/token-validator-service:latest"
  container_port   = 5000
  cpu              = 512
  memory           = 1024
  desired_count    = 1
  token_param_arn  = "arn:aws:ssm:us-east-1:315915553428:parameter/secure_token"
  sqs_arn          = module.messages_queue.sqs_arn
}


module "alfee_site_dns" {
  source      = "./modules/route53"
  domain_name = "alfee.site"
  project     = "Checkpoint"

  records = {
    root = {
      name    = "alfee.site"
      type    = "A"
      ttl     = 300
      records = ["1.2.3.4"]
    }

    www = {
      name    = "www.alfee.site"
      type    = "CNAME"
      ttl     = 300
      records = ["alfee.site"]
    }
  }
}
