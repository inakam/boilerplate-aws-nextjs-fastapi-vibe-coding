# このドメインはAWSアカウントのRoute53で事前に作成しておく
variable "root_domain" {
  default = "[設定したドメイン]" // 例: example.com
}

provider "aws" {
  region                   = "ap-northeast-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "[使用するプロファイル名]"
}

// 証明書の作成でus-east-1が必要なため、別のプロバイダを作成
provider "aws" {
  alias   = "virginia"
  region  = "us-east-1"
  profile = "[使用するプロファイル名]"
}

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    encrypt                 = true
    bucket                  = "[stateを保存するS3バケット名]"
    region                  = "ap-northeast-1"
    key                     = "terraform-aws-fastapi-nextjs.tfstate"
    shared_credentials_file = "~/.aws/credentials"
    profile                 = "[使用するプロファイル名]"
  }
}

# variable
variable "name" {
  default = "aws-lambda-fastapi-nextjs"
}

variable "profile_name" {
  default = "[使用するプロファイル名]"
}

variable "region" {
  default = "ap-northeast-1"
}
