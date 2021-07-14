# Terraform module K8s apps environments (v1.0.2)

[![pipeline status](https://gitlab.aws-gopoints.ru/terraform/mod-k8s-apps/badges/master/pipeline.svg)](https://gitlab.aws-gopoints.ru/terraform/mod-k8s-apps/commits/master)

[1]: https://www.terraform.io/downloads.html

## Description

Terraform module for configuring
 - namespaces in k8s clusters
 - RBAC related configs for namespaces
 - limitranges and quota for namespaces
 - Docker registries for products (ECR)
 - AWS IAM roles for K8s user access management
 - AWS IAM roles for applications
 - Route53 records for services

`namespaces` variable full example: 
```json
   {
     name           = "test-app"
     product        = "testing product",
     owner          = "@pzelensky",
     cluster_editor = false,
     pods           = 10,
     envs = [
       "stg",
       "prod"
     ],
     ecrs = [
       "app",
       "nginx",
       "api",
     ]
     volumes      = 1,
     volumes_size = "1Gi",
  
     ### All parameters below are optional
     // limit_ranges
     default_limit_mem   = "5Gi",
     default_limit_cpu   = "625m",
     default_request_mem = "512Mi",
     default_request_cpu = "125m"
     // object_counts
     secrets      = 300,
     ingresses    = 300,
     cronjobs     = 300,
     jobs         = 300,
     configmaps   = 300,
     services     = "pods",
     deployments  = "pods",
     statefulsets = "pods",
  
     // additional roles (not conformed with template) to be allowed in namespace
     app_iam_roles = [
       "kube-role/test-role-1",
       "kube-role/test-role-2",
     ],
  
     // IAM roles for applications - will be created together with assume policy
     create_app_iam_roles = [
       "test-role-application-1",
       "test-role-application-2",
     ],
  
     // Annotations and labels for objects
     annotations = {
       developed-by = "pzelensky@gmail.com",
     },
     labels = {
       component       = "lmg-apps",
       istio-injection = "enabled",
     },
  
     // Okta Supergroup with access for this NS
     group_name = "Super-K8s-Developer",
  
     // R53 records
     r53 = {
       "waf-private" = {
         hostnames = [
           "zzzz-test-app.aws-gopoints.ru",
           "zzzz-test-app-api.aws-gopoints.ru"
         ]
         private = true
       }
       "waf-public" = {
         hostnames = [
           "zzzz-test-app-public-api.aws-gopoints.ru",
           "zzzz-test-app-public-api-v2.aws-gopoints.ru",
         ]
         private = false
       }
     },
   }
```


## Requirements

* [Terraform 0.12.x][2]
