provider "aws" {
  region = "me-south-1"
  profile = "terraform-operator"
}

data "aws_availability_zones" "available" {
  
}

output "AZs" {
  value = data.aws_availability_zones.available.names
  description = "list of AWS Availability Zones within the region "
}
