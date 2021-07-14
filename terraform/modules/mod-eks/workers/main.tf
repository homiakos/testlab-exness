# single az worker asgs
module "single_az_asg" {
  source = "../asg"

  worker_instance_asgs = var.workers_single_az_asg
  single_az            = true

  cluster_name              = var.cluster_name
  offering                  = var.offering
  ami_id                    = var.ami_id
  ssh_key                   = var.ssh_key
  security_group_ids        = [aws_security_group.workers.id]
  userdata                  = local.userdata
  iam_instance_profile_name = aws_iam_instance_profile.workers.name
  common_tags = {
    "k8s.io/cluster-autoscaler/enabled"             = "true"
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
  }
}

# multi az worker asgs
module "multi_az_asg" {
  source = "../asg"

  worker_instance_asgs = var.workers_multi_az_asg
  single_az            = false

  cluster_name              = var.cluster_name
  offering                  = var.offering
  ami_id                    = var.ami_id
  ssh_key                   = var.ssh_key
  security_group_ids        = [aws_security_group.workers.id]
  userdata                  = local.userdata
  iam_instance_profile_name = aws_iam_instance_profile.workers.name
  common_tags = {
    "k8s.io/cluster-autoscaler/enabled"             = "true"
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
  }
}

# canary multi az worker asgs
module "canary_multi_az_asg" {
  source = "../asg"

  worker_instance_asgs = var.canary_workers_multi_az_asg
  single_az            = false

  cluster_name              = var.cluster_name
  offering                  = var.offering
  ami_id                    = var.canary_ami_id
  ssh_key                   = var.ssh_key
  security_group_ids        = [aws_security_group.workers.id]
  userdata                  = local.userdata
  iam_instance_profile_name = aws_iam_instance_profile.workers.name
  common_tags = {
    "k8s.io/cluster-autoscaler/enabled"             = "true"
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
  }
}

locals {
  userdata = <<USERDATA
#!/bin/bash
set -o xtrace

KUBELET_CONFIG=/etc/kubernetes/kubelet/kubelet-config.json
echo "$(jq ".eventRecordQPS=100" $KUBELET_CONFIG)" > $KUBELET_CONFIG
echo "$(jq ".eventBurst=200" $KUBELET_CONFIG)" > $KUBELET_CONFIG
echo "$(jq ".kubeAPIQPS=100" $KUBELET_CONFIG)" > $KUBELET_CONFIG
echo "$(jq ".kubeAPIBurst=200" $KUBELET_CONFIG)" > $KUBELET_CONFIG

DOCKER_CONFIG=/etc/docker/daemon.json
if [ ! -f $DOCKER_CONFIG ]; then echo '{}' > $DOCKER_CONFIG; fi
echo $(jq '."registry-mirrors"=["${var.dockerhub_proxy}"]' $DOCKER_CONFIG) > $DOCKER_CONFIG
systemctl restart docker
/etc/eks/bootstrap.sh --b64-cluster-ca "${var.cluster_ca}" --apiserver-endpoint "${var.cluster_endpoint}" \
USERDATA
}
