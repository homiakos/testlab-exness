resource "aws_subnet" "private" {
  for_each          = var.private_networks
  availability_zone = each.key
  cidr_block        = each.value
  vpc_id            = aws_vpc.vpc.id
  tags = {
    Name        = "private-${replace(lower(var.vpc_name), " ", "_")}-${each.value}"
    ManagedBy   = "DevOps"
    Project     = var.project
    Environment = var.environment
  }
  map_public_ip_on_launch = false
  depends_on              = [aws_vpc.vpc]
}

resource "aws_route_table" "vpc_private_rt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "private-${var.project}"
  }
}

resource "aws_route" "private_default_route" {
  route_table_id         = aws_route_table.vpc_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

resource "aws_route_table_association" "private_default_route" {
  for_each       = var.private_networks
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.vpc_private_rt.id
}

resource "aws_eip" "nat_ip" {
  tags = {
    ManagedBy   = "DevOps"
    Project     = var.project
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_ip.id
  subnet_id     = aws_subnet.public.0.id

  tags = {
    ManagedBy   = "DevOps"
    Project     = var.project
    Environment = var.environment
    Name        = "nat-${replace(lower(var.vpc_name), " ", "_")}"
  }

}
