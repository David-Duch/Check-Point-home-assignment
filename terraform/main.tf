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
