#Data resoruces to get the az in regions deploying to
data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.env_name
  cidr = var.cidr_block

  azs             = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1], data.aws_availability_zones.available.names[2]]
  private_subnets = [cidrsubnet(var.cidr_block, 4, 0), cidrsubnet(var.cidr_block, 4, 1), cidrsubnet(var.cidr_block, 4, 2)]
  public_subnets  = [cidrsubnet(var.cidr_block, 4, 3), cidrsubnet(var.cidr_block, 4, 4), cidrsubnet(var.cidr_block, 4, 5)]

  enable_nat_gateway     = true
  one_nat_gateway_per_az = true

  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

}