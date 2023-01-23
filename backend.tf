terraform {
  backend "s3" {
    bucket = "nanoshots-tfstates"
    key    = "economia-popular-aws-batch-workflow"
    region = "us-east-1"
  }
}