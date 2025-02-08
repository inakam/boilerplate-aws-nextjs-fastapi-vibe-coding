# AWS (Terraform) + Next.js + FastAPI ボイラープレート

ローカル環境のTerraformから操作を行い、AWS上にフロントエンド(Next.js)とバックエンド(FastAPI)、静的ファイル用バケットを、CloudFrontによるCDN配信も含めて一括でデプロイするボイラープレートです。サーバレスで構築するため、コストを抑えつつスケーラブルな構成が可能です。  
ハッカソンなどで短時間で最低限の環境を構築する必要がある場合に利用できます。

## 概要

- フロントエンド
  - Next.js
    - TypeScript
    - Tailwind CSS
    - ESLint
  - [AWS Lambda Web Adapter](https://github.com/awslabs/aws-lambda-web-adapter)を用いてLambda Containerへデプロイを行います
- バックエンド
  - FastAPI
    - Python
  - AWS Lambda Containerにデプロイを行います
  - DynamoDBを利用してデータを保存します
- インフラ
  - TerraformによるIaC
    - 一連のデプロイをまとめるツールとしてもTerraformが機能しています
    - Dockerイメージはローカルでビルドを行い、ECRにローカルからプッシュを行います
  - あらかじめRoute53のドメインを取得しておく必要があります
    - 設定されたドメインから自動的にサブドメインを生成し、それぞれのサービスを自動的に紐付けます

## 実行方法

### インストール

- Docker
- Terraform
- AWS CLI

```console
brew install terraform awscli
brew install --cask docker
```

### 初期設定

- AWS CLIでプロファイルを設定
  - `aws configure --profile [使用するプロファイル名]`
- Route53のコンソール上から設定したいドメインを取得
  - このドメインを使ってサブドメインを生成します
- S3のバケットを ap-northeast-1 で作成
  - S3にstateファイルを保存するためのバケットを作成します
- `terraform/variables.tf` の修正
  - variable "root_domain" の値を取得したドメインに変更
  - `[使用するプロファイル名]`となっている箇所（4箇所）を自身のプロファイル名に変更
  - `backend "s3"` の `bucket` を先に作成したS3のバケット名に変更
  - `terraform/variables.tf` の `name` の値を任意の名前に修正
    - 複数のプロダクトをこのテンプレートでデプロイすると作成するバケット名などが衝突する可能性があるため、一意の名前にしてください

### ローカル開発

```console
docker compose build
docker compose up
```

- `cd [frontend|backend]` でそれぞれのディレクトリに移動してdocker compose upを実行することで、それぞれのサービスのみをローカルで起動することもできます
- フロントエンド
  - `http://localhost:3001`
- バックエンド
  - `http://localhost:12000/docs`

## デプロイ

- CloudFrontのディストリビューション作成などもあるため、初期構築には10分程度かかります

```console
cd terraform
terraform init
terraform apply
```
