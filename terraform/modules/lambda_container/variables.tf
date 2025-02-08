variable "name" {
  description = "The name of the ECR repository and Lambda function"
  type        = string
}

variable "lambda_docker_src_path" {
  description = "The path to the Dockerfile for the Lambda function"
  type        = string
}

variable "dockerfile_name" {
  description = "The name of the Dockerfile"
  default     = "Dockerfile"
  type        = string
}

variable "lambda_environment_variables" {
  description = "The environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "docker_build_arg" {
  description = "The build argument for the Docker image"
  type        = map(string)
  default     = {}
}

variable "aws_profile_for_lambda_update" {
  description = "The AWS profile to use for updating the Lambda function"
  type        = string
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
  default     = "ap-northeast-1"
}
