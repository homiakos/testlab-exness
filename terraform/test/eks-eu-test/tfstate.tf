# execute `terraform init` to set AWS s3 credentials
terraform {
  backend "s3" {
  }
}

// get account id
data "aws_caller_identity" "current" {
}

# used to get data from tf state file

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "exness-tfstate"
    key    = "${var.project}/terraform/${var.vpc_environment}/vpc/terraform.tfstate"
    region = "eu-central-1"
  }
}

#data "terraform_remote_state" "vpn" {
#  backend = "s3"
#
#  config = {
#    bucket = "exness-tfstate"
#    key    = "${var.project}/${data.aws_caller_identity.current.account_id}/${var.vpc_environment}/vpn/terraform.tfstate"
#    region = "eu-central-1"
#  }
#}
