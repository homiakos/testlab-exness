#!/bin/bash
echo -n "Enter AWS_PROFILE: "
read AWS_PROFILE
echo "\"AWS_PROFILE\" = "$AWS_PROFILE""
export TF_VAR_test_aws_profile=$AWS_PROFILE
echo -n "Enter Terraform bucket s3 state: "
read S3BUCKET
echo "\"S3BUCKET\" = "$S3BUCKET""
sed "s/S3BUCKET/$S3BUCKET/g" < config.tmpl >  ./config.ini
echo -n "Enter Subnet Prefix for create networks example "10.2": "
read SUBNETPREFIX
echo "\"SUBNETPREFIX\" = "$SUBNETPREFIX""
aws configure
aws s3api create-bucket --bucket ${S3BUCKET} --create-bucket-configuration LocationConstraint=eu-central-1
sed "s/SUBNETPREFIX/$SUBNETPREFIX/g" < ./terraform/test/vpc/settings.auto.tfvars.tmpl >  ./terraform/test/vpc/settings.auto.tfvars
sed "s/SUBNETPREFIX/$SUBNETPREFIX/g" < ./terraform/test/eks-eu-test/settings.tf.tmpl >  ./terraform/test/eks-eu-test/settings.tf
cd terraform/test/vpc && inv init && terraform apply  -auto-approve && cd ../../../
cd terraform/test/key-pair && inv init && terraform apply  -auto-approve &&  cd ../../../
cd terraform/test/eks-eu-test && inv init &&terraform apply -target   aws_subnet.eks_asg_sz_private -auto-approve && terraform apply  -auto-approve &&  cd ../../../
aws eks --region eu-central-1 update-kubeconfig --name eks-eu-test
cd terraform/test/iam && inv init && terraform apply  -auto-approve &&  cd ../../../
cd terraform/test/namespaces && inv init && terraform apply  -auto-approve &&  cd ../../../
cd anslible && ansible-playbook -i inventories/eks-eu-test/ all.yml 
ELB=$(kubectl -n apps-test get svc php-nginx-phpfpm-nginx  -o jsonpath='{ .status.loadBalancer.ingress[].hostname }')
while [[
     "$(curl -s -o /dev/null -w ''%{http_code}'' $ELB/health.php)" != "200" 
     ]];
    do sleep 5;
    printf '.'
done

echo -e "\e[32m$ELB/health.php get 200 status code\e[0m"