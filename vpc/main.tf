########## Explicitly state which provider to use
provider "aws" {}

########## Declare varibales to be used - passed from calling main.tf
variable "vpcCIDRblock" {}
variable "instanceTenancy" {}
variable "dnsSupport" {}
variable "dnsHostNames" {}
variable "environment" {}
variable "vpcname" {}
variable "availabilityZoneA" {}
variable "availabilityZoneB" {}
variable "subnetCIDRblockPublicA" {}
variable "subnetCIDRblockPublicB" {}
variable "subnetCIDRblockPrivateA" {}
variable "subnetCIDRblockPrivateB" {}
variable "InternetCIDRblock" {}



######### create the VPC
resource "aws_vpc" "VPC-01" {
  cidr_block           = var.vpcCIDRblock
  instance_tenancy     = var.instanceTenancy
  enable_dns_support   = var.dnsSupport
  enable_dns_hostnames = var.dnsHostNames
  tags = {
    Name = "${var.vpcname}_${var.environment}_tf"
    Env  = var.environment
    CreatedBy = "Terraform"
  }
} # end resource

########## create the Public Subnet A
resource "aws_subnet" "Public-2a" {
  vpc_id                  = aws_vpc.VPC-01.id
  cidr_block              = var.subnetCIDRblockPublicA
  map_public_ip_on_launch = true
  availability_zone       = var.availabilityZoneA
  tags = {
    Name = "Public-2a"
    Env  = var.environment
    CreatedBy = "Terraform"
  }
} # end resource

########## create the Public Subnet B
resource "aws_subnet" "Public-2b" {
  vpc_id                  = aws_vpc.VPC-01.id
  cidr_block              = var.subnetCIDRblockPublicB
  map_public_ip_on_launch = true
  availability_zone       = var.availabilityZoneB
  tags = {
    Name = "Public-2b"
    Env  = var.environment
    CreatedBy = "Terraform"
  }
} # end resource

########### create the Private Subnet A
resource "aws_subnet" "Private-2a" {
  vpc_id                  = aws_vpc.VPC-01.id
  cidr_block              = var.subnetCIDRblockPrivateA
  map_public_ip_on_launch = false
  availability_zone       = var.availabilityZoneA
  tags = {
    Name = "Private-2a"
    Env  = var.environment
    CreatedBy = "Terraform"
  }
} # end resource

########## create the Private Subnet B
resource "aws_subnet" "Private-2b" {
  vpc_id                  = aws_vpc.VPC-01.id
  cidr_block              = var.subnetCIDRblockPrivateB
  map_public_ip_on_launch = false
  availability_zone       = var.availabilityZoneB
  tags = {
    Name = "Private-2b"
    Env  = var.environment
    CreatedBy = "Terraform"
  }
} # end resource

########## Edit the VPC Default Network Access Control List
resource "aws_default_network_acl" "defaultACL" {
  default_network_acl_id = aws_vpc.VPC-01.default_network_acl_id

  # deny ingress CIDR block - bad actors
  ingress {
    protocol   = "-1"
    rule_no    = 5
    action     = "deny"
    cidr_block = "123.148.0.0/16"
    from_port  = 0
    to_port    = 0
  }
  # deny ingress CIDR block - bad actors
  ingress {
    protocol   = "-1"
    rule_no    = 10
    action     = "deny"
    cidr_block = "51.38.236.195/32"
    from_port  = 0
    to_port    = 0
  }
  # deny ingress CIDR block - bad actors
  ingress {
    protocol   = "-1"
    rule_no    = 15
    action     = "deny"
    cidr_block = "185.211.245.128/25"
    from_port  = 0
    to_port    = 0
  }
  # deny ingress CIDR block - bad actors
  ingress {
    protocol   = "-1"
    rule_no    = 20
    action     = "deny"
    cidr_block = "183.150.0.0/16"
    from_port  = 0
    to_port    = 0
  }
  # deny ingress CIDR block - bad actors
  ingress {
    protocol   = "-1"
    rule_no    = 25
    action     = "deny"
    cidr_block = "5.188.210.0/24"
    from_port  = 0
    to_port    = 0
  }
  # deny ingress CIDR block - bad actors
  ingress {
    protocol   = "-1"
    rule_no    = 30
    action     = "deny"
    cidr_block = "114.240.0.0/12"
    from_port  = 0
    to_port    = 0
  }
  # deny ingress CIDR block - bad actors - China
  ingress {
    protocol   = "-1"
    rule_no    = 35
    action     = "deny"
    cidr_block = "120.24.0.0/14"
    from_port  = 0
    to_port    = 0
  }
  # allow ingress all traffic
  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = aws_vpc.VPC-01.cidr_block
    from_port  = 0
    to_port    = 0
  }
  # all egress all traffic
  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  # assign tag
  tags = {
    Name = "NACL-LivOliv-Default-TF"
    Env  = var.environment
    CreatedBy = "Terraform"
  }
}

########## Create the Internet Gateway and associate with production VPC
resource "aws_internet_gateway" "IGW-01" {
  vpc_id = aws_vpc.VPC-01.id
  tags = {
    Name = "IGW-LivOliv-TF"
    Env  = var.environment
    CreatedBy = "Terraform"
  }
} # end resource

########## Create the Internet Route Table
resource "aws_route_table" "RTB-Internet-01" {
  vpc_id = aws_vpc.VPC-01.id
  tags = {
    Name = "RTB-LivOliv-Internet-TF"
    Env  = var.environment
    CreatedBy = "Terraform"
  }
} # end resource

########## Create Route to the Internet via Internet Gateway and add to Internet Route Table
resource "aws_route" "internet_route_access" {
  route_table_id         = aws_route_table.RTB-Internet-01.id
  destination_cidr_block = var.InternetCIDRblock
  gateway_id             = aws_internet_gateway.IGW-01.id
} # end resource

########## Associate the Public-2a Subnet with the Internet Route Table
resource "aws_route_table_association" "Public-2a-Association" {
  subnet_id      = aws_subnet.Public-2a.id
  route_table_id = aws_route_table.RTB-Internet-01.id
} # end resource

########## Associate the Public-2b Subnet with the Internet Route Table
resource "aws_route_table_association" "Public-2b-Association" {
  subnet_id      = aws_subnet.Public-2b.id
  route_table_id = aws_route_table.RTB-Internet-01.id
} # end resource

########## Edit the LivOliv VPC Default Route Table
# The Default Route Table will be associated with the private subnets by default
resource "aws_default_route_table" "defaultRTB" {
  default_route_table_id = aws_vpc.VPC-01.default_route_table_id

  #  route {
  #    cidr_block = vpcCIDRblock
  #  }

  tags = {
    Name = "RTB-LivOliv-Default-Route-Table-TF"
    Env  = var.environment
    CreatedBy = "Terraform"
  }
}

# end vpc.tf