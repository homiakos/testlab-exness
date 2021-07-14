output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "nat_instances" {
  value = module.vpc.nat_instances
}

output "private_networks" {
  value = values(var.private_networks)
}

output "public_networks" {
  value = values(var.public_networks)
}


output "central_igw_id" {
  value = module.vpc.central_igw
}

output "public_rt" {
  value = module.vpc.public_rt
}

output "private_rts" {
  value = module.vpc.private_rts
}

output "private_rts_rt" {
  value = module.vpc.private_rts_rt
}

output "cidr" {
  value = var.vpc_cidr
}

output "vpn_sg" {
  value = aws_security_group.vpn_sg.id
}
