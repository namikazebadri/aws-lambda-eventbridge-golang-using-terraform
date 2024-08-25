variable "LAMBDA_ENV" {
  type = string
}

variable "iam_role" {
  description = "IAM Role for Lambda."
}

variable "scheduler_iam_role" {
  description = "IAM Role for Scheduler."
}