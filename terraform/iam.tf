# lambda用Roleの設定
resource "aws_iam_role" "lambda_iam_role" {
  name = "${var.name}-terraform-lambda-iam-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

# lambda用Policyの作成
resource "aws_iam_role_policy" "lambda_access_policy" {
  name   = "${var.name}-terraform-lambda-access-policy"
  role   = aws_iam_role.lambda_iam_role.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:CreateLogGroup",
        "logs:PutLogEvents",
        "s3:*",
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:Query",
        "bedrock:InvokeModel"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}
