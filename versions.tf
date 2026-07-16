terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # Bucket, region, encryption, and locking stay fixed here.
  # "key" is intentionally left out - it is passed at init time so each
  # branch/environment (dev, staging, main) writes to its own state file
  # in the same bucket, instead of overwriting each other.
  backend "s3" {
    bucket       = "my-tf-state-blog"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"
}
