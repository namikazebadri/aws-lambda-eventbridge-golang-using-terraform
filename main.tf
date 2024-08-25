terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    archive = {
      source = "hashicorp/archive"
    }
    null = {
      source = "hashicorp/null"
    }
  }

  required_version = ">= 1.3.7"
}

provider "aws" {
  region  = "ap-southeast-1"
}

module "cart_crontab" {
  source = "./lambda/cart/crontab"
  iam_role = aws_iam_role.lambda.arn
  scheduler_iam_role = aws_iam_role.scheduler_role
  LAMBDA_ENV = var.LAMBDA_ENV
}

module "order_crontab" {
  source = "./lambda/order/crontab"
  iam_role = aws_iam_role.lambda.arn
  scheduler_iam_role = aws_iam_role.scheduler_role
  LAMBDA_ENV = var.LAMBDA_ENV
}

module "product_crontab" {
  source = "./lambda/product/crontab"
  iam_role = aws_iam_role.lambda.arn
  scheduler_iam_role = aws_iam_role.scheduler_role
  LAMBDA_ENV = var.LAMBDA_ENV
}

module "user_crontab" {
  source = "./lambda/user/crontab"
  iam_role = aws_iam_role.lambda.arn
  scheduler_iam_role = aws_iam_role.scheduler_role
  LAMBDA_ENV = var.LAMBDA_ENV
}

output "status" {
  value = "Success"
}