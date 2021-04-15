# Demo on how to use Terraform ranging from basic to pipeline

This code base helps breakdown how to use terraform using simple examples to establish understanding of key concepts

## Topics covered per module

* 1-Basics: Getting started, setting up `main.tf` using `terraform init`, `terraform plan`, `terraform apply` commands
* 2-RemoteState: Setting up a remote state to ensure the code doesn't continous deploy and it's centrally managed
* 3-Variables: Setting up varibles to provide data to resoruce parameters
* 4-Modules: Referencing modules `3-Varibales` stack to deploy the same resource
* 5-FinalProduct: Using [AWS CodeBuild]() and [AWS CodePipeline]() to setup a terrform pipeline to deploy the stack using the `buildspec.yaml` file to orchestrate the build 

# Usage

## Pre-requisites

Prior to using this repo you will need terraform installed on the system running the code link to Terraform site below:

* [Terraform Download](https://www.terraform.io/downloads.html)
* [Terraform Install Guide](https://learn.hashicorp.com/terraform/getting-started/install)

# Running the Code

## 1-Basics:

This directory is intended to be run locally

Getting started you'll need to open a `terminal` window and change direcotries to the working directory (ex `cd ./tf_demo/1-Basics/`)

Next you need to instantiate the terraform working environment by running the following command `terraform init`

Once complete you're ready to use terraform to deploy the resources defined in `main.tf`. It's recommended to do a dry run first by running the command `terraform plan`
This will show you what changes are going to happen without *any* chance of it deploying

```
C:\Users\fargano\tf_demo\1-Basics>terraform plan

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_vpc.this will be created
  + resource "aws_vpc" "this" {
      + arn                              = (known after apply)
      + assign_generated_ipv6_cidr_block = false
      + cidr_block                       = "10.0.0.0/16"
      + default_network_acl_id           = (known after apply)
      + default_route_table_id           = (known after apply)
      + default_security_group_id        = (known after apply)
      + dhcp_options_id                  = (known after apply)
      + enable_classiclink               = (known after apply)
      + enable_classiclink_dns_support   = (known after apply)
      + enable_dns_hostnames             = (known after apply)
      + enable_dns_support               = true
      + id                               = (known after apply)
      + instance_tenancy                 = "default"
      + ipv6_association_id              = (known after apply)
      + ipv6_cidr_block                  = (known after apply)
      + main_route_table_id              = (known after apply)
      + owner_id                         = (known after apply)
      + tags_all                         = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```
To build out the resources defined use the command `terrafrom apply` 
This will provide the same output as above but now you'll be prompted to confirm the build/changes

```
...
Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.
```

In order to remove the resources from your environment run the command `terraform destroy`
When using in practice take *EXTREME* caution using this command as it will remove *ALL* resources defined/managed in the `.statefile`

## 2-RemoteState

One of many issues with the above is that it creates the `.statefile` locally and is stored in the `.git` repo. In order to remove this and have a centrally managed `.statefile` you need to define remote location you wish to use. Terraform supports sever [bankends](https://www.terraform.io/docs/language/settings/backends/index.html), the example in this repo uses the [s3 backend](https://www.terraform.io/docs/language/settings/backends/s3.html)

The changes made here are separating the `provider` and `terraform` definitions to their own `config.tf` file. Below is the code snippet to setup the remote backend

```
terraform {
  backend "s3" {
    region  = "us-east-1"
    bucket = "fargano-statefiles"
    key    = "tf-demo/remote-state-demo.tfstate"
    encrypt        = "true"
    dynamodb_table = "fargano-tflock"
  }
}
```

## 3-Variables

Similarly to the `2-RemoteState` directory here we are resolving the issue of hardcoding data into the resources by leveraging variables. Separating them out into their own `variables.tf` file I've defined and set default values for each variable. For manual input of each comment out the `default` values for each or for supplying values to overwrite the default values you can use `<filename>.json` file with values and using the command `terraform apply -var-file=<filename>.json`. See `5-FinalProduct` for an example

```
variable "env_name" {
  description = "the name of your stack, e.g. \"demo\""
  #default     = "demo"
}

variable "region" {
  description = "the AWS region in which resources are created, you must set the availability_zones variable as well if you define this value to something other than the default"
  #default     = "us-east-1"
}

variable "cidr_block" {
  description = "The CIDR block for the VPC."
  #default     = "10.0.0.0/16"
}
```
```
resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  tags = {
    Name = var.env_name
  }
}
```
## 4-Modules

Once you create a terraform directory that uses varibles you can now leverage that as a module to create repeatable deployments using the same codebase. The code here references the terraform code from `3-Variables` as a module to deploy the resrouces defined there. Also avaialble are the [community managed module](https://registry.terraform.io/) 

```
module "vpc" {
  source = "../3-Variables"
  region = var.region
  env_name=var.env_name
  cidr_block = var.cidr_block
}
```

## 5-FinalProduct

Using everything we've learned above we can know combine it all together and deploy using a pipeline. Key concept used in this section is the `data` resoruce which is able to pull in data about a resource even if it's not managed by terraform as a reference in the deployment. This example I use it to get the availability zone avaialble in this region to define which ones to use. Addtionally using the `cidrsubnet()` intrinsic function allows me to programmaticlly define what each subnet should look like. This allows this code base to be an idempotent deployment

```
data "aws_availability_zones" "available" {
  state = "available"
}
...
private_subnets = [cidrsubnet(var.cidr_block, 4, 0), cidrsubnet(var.cidr_block, 4, 1), cidrsubnet(var.cidr_block, 4, 2)]
```