resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.eks_cluster_name}-cluster"
  description = "EKS cluster Security group"

  vpc_id = var.eks_vpc_id
}

resource "aws_security_group_rule" "allow_access_from_admin_sg" {
  for_each                 = toset(var.admin_sg)
  from_port                = 443
  to_port                  = 443
  protocol                 = "TCP"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  type                     = "ingress"
  source_security_group_id = each.key
}

resource "aws_security_group_rule" "allow_access_from_admin_networks" {
  count             = length(var.admin_networks) > 0 ? 1 : 0
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  security_group_id = aws_security_group.eks_cluster_sg.id
  type              = "ingress"
  cidr_blocks       = var.admin_networks
}
