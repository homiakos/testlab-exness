resource "aws_vpc_endpoint" "s3_ep" {
  count        = var.s3_endpoint == "" ? 0 : 1
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.eu-central-1.s3"
}

resource "aws_vpc_endpoint_route_table_association" "main_rt_private_ep" {
  count           = length(keys(var.private_networks)) * (var.s3_endpoint == "" ? 0 : 1)
  vpc_endpoint_id = aws_vpc_endpoint.s3_ep.0.id
  route_table_id  = element(aws_route_table.vpc_private_rt.*.id, count.index)
}

