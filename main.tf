provider "aws" {
  region = "ap-southeast-1"
  profile = "terraform-operator"
}

data "aws_availability_zones" "available" {
  
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.6.0"
  name = "vpc-awesome"
  cidr = "10.0.0.0/16" # 192.168 , 172.16
  azs = data.aws_availability_zones.available.names
  public_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/awesome" = "shared"
  }

}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "7.0.0"
  # insert the 4 required variables here
  cluster_name = "awesome"
  subnets = module.vpc.public_subnets
  vpc_id = module.vpc.vpc_id
  # worker nodes
  worker_groups_launch_template = [
    {
      name                 = "worker-group-1"
      instance_type        = "t3.large"
      asg_desired_capacity = 2
      public_ip            = true
    }
  ]

}
