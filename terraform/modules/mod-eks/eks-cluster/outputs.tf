output "eks_ca" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "security_group" {
  value = aws_security_group.eks_cluster_sg.id
}

output "kubeconfig" {
  value = local.kubeconfig
}

output "oidc" {
  value = {
    url = replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")
    arn = aws_iam_openid_connect_provider.oidc.arn
  }
}
