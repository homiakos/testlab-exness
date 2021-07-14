# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
module "aws_test_service_key" {
  source = "../../modules/key-pair"
 key_name   = "exness-test"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDm4UjBExW5/fZifJDSmRSuUj1hjphp3kfE2cdxFUlU8G9bB66OWglfbYGP0AvS4T3VzpaNws91+l7nBJ3ERfsolBHiVNLknJ0qo28dzh5dwhyFq8iVZJe1zil7/DE9d5fI9FNoCpC3YH49zjtktuhitvwEWlvtPJgI3oaObHRolInb5GDhBNZcuelDFE+KbC8pfqgqRC7PrsGLJdemPFju7U/t89hMSVEbbj8MxnbGPK5Mz+hcy0ZanFjpdUdxjV8JS+T3RG62d9dBhAGheICg7P3Y5o8WxiMHCS5aTcbC2I3qdgvTfg+2U8aa9YG2JJCektK/jZ/9Q9ykgAvyeH5R4VJkAY6l7AIrXHGnn91Ms+eDp2fXuk5J8aAwVpLKuz5OSFwZ05Ygr1Gh+f7kgkehyBWWVsp4XX914DU1T56DMvVi/Ux8ssZvwUSXVOSTvU+U26x/54IvDxI8/MkbXSZIBJOtF6rTrKxqGxwhk2F1MKixu7kRE+bujLeG9K4hO68=  aws_exness_test"
 }
