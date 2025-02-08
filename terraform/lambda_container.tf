module "frontend" {
  source = "./modules/lambda_container"

  name                   = "${var.name}-frontend"
  lambda_docker_src_path = "../frontend"
  dockerfile_name        = "Dockerfile-lambda"

  lambda_environment_variables = local.frontend_environment
  docker_build_arg             = local.frontend_environment

  aws_profile_for_lambda_update = var.profile_name
  aws_region                    = var.region
}

locals {
  frontend_environment = {
    HOGE = "1"
  }
}

module "backend" {
  source = "./modules/lambda_container"

  name                   = "${var.name}-backend"
  lambda_docker_src_path = "../backend"
  dockerfile_name        = "Dockerfile-lambda"

  lambda_environment_variables = local.backend_environment
  docker_build_arg             = local.backend_environment

  aws_profile_for_lambda_update = var.profile_name
  aws_region                    = var.region
}

locals {
  backend_environment = {
    FUGA = "1"
  }
}
