terraform {
  backend "s3" {
    bucket = "strapi-tf-backend-siri-2026-unique"
    key    = "infra/terraform.tfstate"
    region = "us-east-1"
  }
}