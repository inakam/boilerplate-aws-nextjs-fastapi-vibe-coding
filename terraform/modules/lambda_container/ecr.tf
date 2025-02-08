################################################################################
# ECR                                                                          #
################################################################################
resource "aws_ecr_repository" "ecr" {
  name = var.name

  force_delete = true
}

locals {
  ecr_endpoint = split("/", aws_ecr_repository.ecr.repository_url)[0]
}

data "aws_caller_identity" "current" {}

resource "null_resource" "image_push" {
  triggers = {
    code_diff = sha512(join("", [
      for file in fileset(var.lambda_docker_src_path, "**/*")
      : filesha256("${var.lambda_docker_src_path}/${file}")
    ]))
  }

  provisioner "local-exec" {
    working_dir = var.lambda_docker_src_path
    command     = <<-EOF
      aws ecr get-login-password --region ap-northeast-1 --profile ${var.aws_profile_for_lambda_update} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com; \
      docker build . --platform=linux/amd64 -f ${var.dockerfile_name} \
        ${join(" ", [for key, value in var.docker_build_arg : "--build-arg ${key}=${value}"])} \
        -t ${aws_ecr_repository.ecr.repository_url}:latest; \
      docker push ${aws_ecr_repository.ecr.repository_url}:latest
      docker system prune --volumes --force
    EOF
  }
}
