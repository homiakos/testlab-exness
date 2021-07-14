module "vpc" {
  source           = "../../modules/mod-vpc"

  private_networks = var.private_networks
  public_networks  = var.public_networks
  vpc_cidr         = var.vpc_cidr
  vpc_name         = var.vpc_name
  s3_endpoint      = var.s3_endpoint
}

resource "aws_ebs_encryption_by_default" "dance_like_no_one_is_looking_encrypt_like_everyone_does" {
  enabled = true
}
