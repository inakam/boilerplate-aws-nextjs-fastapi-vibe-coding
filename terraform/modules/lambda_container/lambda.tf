################################################################################
# Lambda                                                                       #
################################################################################
resource "aws_lambda_function" "lambda" {
  depends_on = [
    aws_cloudwatch_log_group.lambda,
    null_resource.image_push,
  ]

  function_name = var.name
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.ecr.repository_url}:latest"
  role          = aws_iam_role.lambda.arn
  publish       = true
  architectures = ["x86_64"]

  memory_size = 512
  timeout     = 30

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [image_uri]
  }

  environment {
    variables = var.lambda_environment_variables
  }
}

# ECRにpushしたイメージをLambdaにデプロイするためのnull_resource
# 設定されているプロファイルを使ってLambdaにデプロイする
resource "null_resource" "lambda_deployment" {
  triggers = {
    diff = null_resource.image_push.triggers.code_diff
  }

  provisioner "local-exec" {
    command = "aws lambda update-function-code --function-name ${var.name} --image ${aws_ecr_repository.ecr.repository_url}:latest --region ${var.aws_region} --profile ${var.aws_profile_for_lambda_update}"
  }

  depends_on = [aws_lambda_function.lambda, aws_lambda_function_url.lambda]
}

################################################################################
# IAM Role for Lambda                                                          #
################################################################################
resource "aws_iam_role" "lambda" {
  name               = "${var.name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_custom.arn
}

resource "aws_iam_policy" "lambda_custom" {
  name   = "${var.name}-policy"
  policy = data.aws_iam_policy_document.lambda_custom.json
}

data "aws_iam_policy_document" "lambda_custom" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "*",
    ]
  }
}

################################################################################
# CloudWatch Logs                                                              #
################################################################################
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = 3
}

################################################################################
# Function URLs                                                                #
################################################################################
resource "aws_lambda_function_url" "lambda" {
  function_name      = aws_lambda_function.lambda.function_name
  authorization_type = "NONE"
}
