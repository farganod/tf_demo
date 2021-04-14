module "vpc" {
  source = "../3-Variables"
  region = var.region
  env_name=var.env_name
  cidr_block = var.cidr_block
}
