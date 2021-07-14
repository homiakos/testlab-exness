resource "aws_internet_gateway" "central_igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "public" {
  count             = length(keys(var.public_networks))
  availability_zone = element(keys(var.public_networks), count.index)
  cidr_block        = element(values(var.public_networks), count.index)
  vpc_id            = aws_vpc.vpc.id
  tags = {
    Name      = "public-${replace(lower(var.vpc_name), " ", "_")}-${element(values(var.public_networks), count.index)}"
    ManagedBy = "DevOps"
  }
  lifecycle {
    prevent_destroy = false
  }
  map_public_ip_on_launch = false
  depends_on              = [aws_vpc.vpc]
}

resource "aws_route_table" "vpc_public_rt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "public-${var.project}"
  }
}

resource "aws_route" "public_default_route" {
  route_table_id         = aws_route_table.vpc_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.central_igw.id
}

resource "aws_route_table_association" "public_default_route" {
  count          = length(keys(var.public_networks))
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.vpc_public_rt.id
}

