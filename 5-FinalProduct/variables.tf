
variable "env_name" {
  description = "the name of your stack, e.g. \"demo\""
  default     = "eks-demo"
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
  default     = "dev"
}

variable "region" {
  description = "the AWS region in which resources are created, you must set the availability_zones variable as well if you define this value to something other than the default"
  default     = "us-east-1"
}

variable "cidr_block" {
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "sa_name" {
  description = "Service Account Name"
  default     = "s3-echoer"
}
