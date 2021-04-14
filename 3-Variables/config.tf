terraform {
  backend "s3" {
    region  = "us-east-1"
    bucket = "fargano-statefiles"
    key    = "tf-demo/variables-demo.tfstate"
    encrypt        = "true"
    dynamodb_table = "fargano-tflock"
  }
}

provider "aws"{
    region = var.region
}