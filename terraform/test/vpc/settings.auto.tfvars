project         = "exness"
region          = "eu-central-1"
vpc_environment = "test"
vpc_cidr        = "10.8.0.0/16"

private_networks = {
  eu-central-1a = "10.8.0.0/23"
  eu-central-1b = "10.8.2.0/23"
  eu-central-1c = "10.8.4.0/23"
}

public_networks = {
  eu-central-1a = "10.8.16.0/23"
  eu-central-1b = "10.8.18.0/23"
  eu-central-1c = "10.8.20.0/23"
}

vpc_name    = "exness test VPC"
s3_endpoint = "exness-tfstate"
