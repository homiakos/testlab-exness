#!/bin/bash
echo -n "Enter AWS_PROFILE: "
read AWS_PROFILE
echo "\"AWS_PROFILE\" = "$AWS_PROFILE""
export TF_VAR_test_aws_profile=$AWS_PROFILE
aws configure
kubectl delete ns apps-test
cd terraform/test/iam && inv init && terraform destroy  -auto-approve &&  cd ../../../
cd terraform/test/eks-eu-test && inv init && terraform destroy  -auto-approve &&  cd ../../../
cd terraform/test/key-pair && inv init && terraform destroy  -auto-approve &&  cd ../../../
cd terraform/test/vpc && inv init && terraform destroy  -auto-approve && cd ../../../


