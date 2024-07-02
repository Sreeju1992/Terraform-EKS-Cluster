module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"
  name = local.name
  cidr = local.vpc_cidr
  azs = local.azs

  private_subnets     =  [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets      =  [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]

# Database subnets
  create_database_subnet_group  = true
  create_database_subnet_route_table = true
  database_subnets    = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 8)]
  #create_database_nat_gateway_route = true - commenting this as my database do not need to have outbound communication
  #create_database_internet_gateway_route = true

# NAT gateways - Outbound communication
  enable_nat_gateway = true
  single_nat_gateway = true

# VPC DNS parameters
  enable_dns_hostnames = true
  enable_dns_support = true

  public_subnet_tags = {
    Type = "public-subnets"
  }

  private_subnet_tags = {
    Type = "private-subnets"
  }

  database_subnet_tags = {
    Type = "database-subnets"
  }

  tags = local.common_tags

  vpc_tags = {
    Name = "vpc-dev"
  }
}