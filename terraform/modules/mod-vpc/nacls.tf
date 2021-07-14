resource "aws_network_acl" "vpc_private_nets_acl" {
  count  = length(keys(var.private_networks))
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol   = -1
    rule_no    = 1000
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 1000
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  //  tags {
  //    Name        = "acl-${replace(lower(var.vpc_name), " ", "_")}_${element(values(var.private_networks), count.index)}"
  //    ManagedBy   = "DevOps"
  //    Project     = "${var.project}"
  //    Environment = "${var.environment}"
  //  }
}

resource "aws_network_acl" "vpc_public_nets_acl" {
  count  = length(keys(var.public_networks))
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol   = -1
    rule_no    = 1000
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 1000
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  //  tags {
  //    Name        = "acl-${replace(lower(var.vpc_name), " ", "_")}_${element(values(var.public_networks), count.index)}"
  //    ManagedBy   = "DevOps"
  //    Project     = "${var.project}"
  //    Environment = "${var.environment}"
  //  }
}

