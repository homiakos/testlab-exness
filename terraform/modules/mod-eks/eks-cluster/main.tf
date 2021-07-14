resource "aws_eks_cluster" "eks_cluster" {
  name     = var.eks_cluster_name
  version  = var.eks_cluster_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  enabled_cluster_log_types = var.eks_logs_enabled

  vpc_config {
    endpoint_private_access = true
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
    subnet_ids              = var.eks_private_subnets
  }

  depends_on = [aws_cloudwatch_log_group.eks-logs]
}

resource "aws_cloudwatch_log_group" "eks-logs" {
  name              = "/aws/eks/${var.eks_cluster_name}/cluster"
  retention_in_days = 30
}

locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: "${aws_eks_cluster.eks_cluster.endpoint}"
    certificate-authority-data: "${aws_eks_cluster.eks_cluster.certificate_authority.0.data}"
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.eks_cluster_name}"
KUBECONFIG
}
