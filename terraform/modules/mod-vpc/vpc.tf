resource "aws_vpc" "vpc" {
  cidr_block                       = var.vpc_cidr
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = false
  enable_dns_support               = true
  tags = {
    Name      = var.vpc_name
    ManagedBy = "DevOps"
  }
}
