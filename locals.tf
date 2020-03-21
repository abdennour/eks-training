locals {
  # default, staging
  env = "${terraform.workspace}"

  cluster_name_map = {
    default = "awesome"
    staging = "stagingawesome"
  }

  cluster_name = "${lookup(local.cluster_name_map, local.env)}"

  vpc_cidr_map = {
    default = "10.0.0.0/16"
    staging = "172.16.0.0/16"
  }

  vpc_cidr = "${lookup(local.vpc_cidr_map, local.env)}"


  vpc_subnets_map = {
    default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
    staging  = "${cidrsubnets(local.vpc_cidr,4 ,4 ,4 )}"
  }
 
  vpc_subnets= "${lookup(local.vpc_subnets_map, local.env)}"


}
