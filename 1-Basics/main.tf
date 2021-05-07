provider "aws" {
  region     = "us-east-1"
  #access_key = "my-access-key" never do this
  #secret_key = "my-secret-key" never do this
  profile = "default"
}

provider "aws" {
  alias  = "east2"
  region = "us-east-2"
}


resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_vpc" "that" {
  provider = aws.east2
  cidr_block = "10.0.0.0/16"
}
