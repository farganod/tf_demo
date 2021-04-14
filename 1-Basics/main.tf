provider "aws" {
  region     = "us-east-1"
  #access_key = "my-access-key" never do this
  #secret_key = "my-secret-key" never do this
  profile = "default"
}


resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
}
