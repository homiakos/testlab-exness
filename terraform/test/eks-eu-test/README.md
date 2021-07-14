# Terraform environment for test EKS deployment

[1]: https://www.terraform.io/downloads.html

## Description

This terraform module is used to deploy test EKS cluster for `px019` project.
It creates:

- Networks
- Security groups
- Roles
- EKS cluster
- Autoscaling groups
 - On demand workers using different ec2 instance types
 - Spot workers using different ec2 instance types
 - Canary spot workers to be used for AMI testing

## Requirements

- [Terraform 0.14+][1]

## Development & Deployment

Please refer to [Terraform Development Guide][2] for details.
