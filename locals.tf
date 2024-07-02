locals {
  name   = "hr-dev"
  region = "us-east-1"
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)
  common_tags = {
    owners = "Sreejith-test"
    environment = "dev"
  }
}