output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnets" {
  value = aws_subnet.public
}

output "private_subnets" {
  value = aws_subnet.private
}

output "nat_instances" {
  value = aws_nat_gateway.nat_gw.tags
}

output "central_igw" {
  value = aws_internet_gateway.central_igw.id
}

output "public_rt" {
  value = aws_route_table.vpc_public_rt.id
}

output "private_rts" {
  value = aws_route_table.vpc_private_rt.id
}

output "private_rts_rt" {
  value = aws_route_table.vpc_private_rt
}
