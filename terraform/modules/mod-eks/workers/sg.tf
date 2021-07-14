resource "aws_security_group" "workers" {
  name        = "${var.cluster_name}-workers"
  description = "Security group for all nodes in the ${var.cluster_name} cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = map(
    "Name", "${var.cluster_name}-workers",
    "kubernetes.io/cluster/${var.cluster_name}", "owned"
  )
}

resource "aws_security_group_rule" "workers_ssh" {
  cidr_blocks       = ["10.0.0.0/8"]
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.workers.id
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "worker_to_worker_sg" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = aws_security_group.workers.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_masters_ingress" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = var.cluster_security_group
  type                     = "ingress"
}

resource "aws_security_group_rule" "masters_api_ingress" {
  description              = "Allow cluster control plane to receive communication from worker Kubelets and pods"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = var.cluster_security_group
  source_security_group_id = aws_security_group.workers.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "masters_kubelet_egress" {
  description              = "Allow the cluster control plane to reach out worker Kubelets and pods"
  from_port                = 10250
  protocol                 = "tcp"
  security_group_id        = var.cluster_security_group
  source_security_group_id = aws_security_group.workers.id
  to_port                  = 10250
  type                     = "egress"
}

resource "aws_security_group_rule" "workers_masters_https_ingress" {
  description              = "Allow worker Kubelets and pods to receive https from the cluster control plane"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = var.cluster_security_group
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "masters_kubelet_https_egress" {
  description              = "Allow the cluster control plane to reach out worker Kubelets and pods https"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = var.cluster_security_group
  source_security_group_id = aws_security_group.workers.id
  to_port                  = 443
  type                     = "egress"
}

resource "aws_security_group_rule" "masters_metrics_https_egress" {
  description              = "Allow the cluster control plane to reach out worker Kubelets and pods https"
  from_port                = 6443
  protocol                 = "tcp"
  security_group_id        = var.cluster_security_group
  source_security_group_id = aws_security_group.workers.id
  to_port                  = 6443
  type                     = "egress"
}

resource "aws_security_group_rule" "masters_prometheus-operator_https_egress" {
  description              = "Allow the cluster control plane to reach out worker Kubelets and pods https"
  from_port                = 8443
  protocol                 = "tcp"
  security_group_id        = var.cluster_security_group
  source_security_group_id = aws_security_group.workers.id
  to_port                  = 8443
  type                     = "egress"
}

resource "aws_security_group_rule" "masters_elastic-operator_https_egress" {
  description              = "Allow the cluster control plane to reach out worker Kubelets and pods https"
  from_port                = 9443
  protocol                 = "tcp"
  security_group_id        = var.cluster_security_group
  source_security_group_id = aws_security_group.workers.id
  to_port                  = 9443
  type                     = "egress"
}

resource "aws_security_group_rule" "allow_access_from_admin_sg" {
  for_each                 = toset(var.admin_sg)
  from_port                = 22
  to_port                  = 22
  protocol                 = "TCP"
  security_group_id        = aws_security_group.workers.id
  type                     = "ingress"
  source_security_group_id = each.key
}

resource "aws_security_group_rule" "allow_access_from_admin_networks" {
  count             = length(var.admin_networks) > 0 ? 1 : 0
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  security_group_id = aws_security_group.workers.id
  type              = "ingress"
  cidr_blocks       = var.admin_networks
}
