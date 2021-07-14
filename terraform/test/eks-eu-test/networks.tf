// create private networks

resource "aws_subnet" "eks_private" {
  for_each          = var.private_networks
  vpc_id            = local.vpc_id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name                                          = "${var.project}-${var.vpc_environment}-${local.cluster_name}-eks_private"
    ManagedBy                                     = "DevOps"
    Project                                       = var.project
    Environment                                   = var.vpc_environment
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}

// create public networks

resource "aws_subnet" "eks_public" {
  for_each          = var.public_networks
  vpc_id            = local.vpc_id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name                                          = "${var.project}-${var.vpc_environment}-${local.cluster_name}-eks_public"
    ManagedBy                                     = "DevOps"
    Project                                       = var.project
    Environment                                   = var.vpc_environment
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }
}

// create eks asg networks

resource "aws_subnet" "eks_asg_private" {
  for_each                = var.asg_private_networks
  vpc_id                  = local.vpc_id
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project}-${var.vpc_environment}-${local.cluster_name}-eks_asg_private"
    ManagedBy   = "DevOps"
    Project     = var.project
    Environment = var.vpc_environment
  }
}

// create eks asg networks

resource "aws_subnet" "eks_asg_sz_private" {
  for_each                = var.asg_sz_private_networks
  vpc_id                  = local.vpc_id
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project}-${var.vpc_environment}-${local.cluster_name}-eks_asg_sz_private"
    ManagedBy   = "DevOps"
    Project     = var.project
    Environment = var.vpc_environment
  }
}

// associate route tables with subnets

resource "aws_route_table_association" "private" {
  for_each       = var.private_networks
  subnet_id      = aws_subnet.eks_private[each.key].id
  route_table_id = local.private_route_table_id
  depends_on     = [aws_subnet.eks_private]
}

resource "aws_route_table_association" "asg_private" {
  for_each       = var.asg_private_networks
  subnet_id      = aws_subnet.eks_asg_private[each.key].id
  route_table_id = local.private_route_table_id
  depends_on     = [aws_subnet.eks_asg_private]
}

resource "aws_route_table_association" "asg_sz_private" {
  for_each       = var.asg_sz_private_networks
  subnet_id      = aws_subnet.eks_asg_sz_private[each.key].id
  route_table_id = local.private_route_table_id
  depends_on     = [aws_subnet.eks_asg_sz_private]
}

resource "aws_route_table_association" "public" {
  for_each       = var.public_networks
  subnet_id      = aws_subnet.eks_public[each.key].id
  route_table_id = local.public_route_table_id
  depends_on     = [aws_subnet.eks_public]
}
