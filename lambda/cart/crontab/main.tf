locals {
  project         = "demo"
  module          = "cart"
  function        = "crontab"
  module_function = "${local.module}/${local.function}"
  src_path        = "./lambda/${local.module_function}"
  binary_path     = "./bin/${local.module_function}/bootstrap"
  archive_path    = "./bin/${local.module_function}/${local.function}.zip"
}

resource "null_resource" "function_binary" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "GOOS=linux GOARCH=amd64 CGO_ENABLED=0 GOFLAGS=-trimpath go build -mod=readonly -ldflags='-s -w' -o ${local.binary_path} ${local.src_path}"
  }
}

data "archive_file" "function_archive" {
  depends_on = [null_resource.function_binary]

  type        = "zip"
  source_file = local.binary_path
  output_path = local.archive_path
}

resource "aws_lambda_function" "cart_crontab" {
  function_name = "${var.LAMBDA_ENV}-${local.project}_${local.module}_${local.function}"
  description   = "Lambda for ${local.module} module."
  role          = var.iam_role
  handler       = local.function
  memory_size   = 128

  filename         = local.archive_path
  source_code_hash = data.archive_file.function_archive.output_base64sha256

  runtime = "provided.al2"
}

resource "aws_cloudwatch_event_rule" "crontab_trigger" {
  name                = "${var.LAMBDA_ENV}-${local.project}_${local.module}_${local.function}"
  schedule_expression = "cron(1 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "cart_crontab_trigger_target" {
  rule      = aws_cloudwatch_event_rule.crontab_trigger.name
  target_id = "LambdaTarget"
  arn       = aws_lambda_function.cart_crontab.arn
  input = jsonencode({
    source = "AWS EventBridge"
  })
}

resource "aws_lambda_permission" "allow_event_bridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cart_crontab.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.crontab_trigger.arn
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/lambda/${aws_lambda_function.cart_crontab.function_name}"
  retention_in_days = 7
}
