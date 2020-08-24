########## Retrieve MY IP address
# This will be used to allow SSH access
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}
# End Retrive MY IP Address


########## Create the ELB Security Group
resource "aws_security_group" "SG-ELB-TF" {
  vpc_id      = aws_vpc.VPC-01.id
  name        = "SG-ELB-TF"
  description = "Allow inbound HTTP and HTTPS traffic from the Internet"
  # allow ingress of port 80
  ingress {
    cidr_blocks = [var.InternetCIDRblock]
    #ipv6_cidr_blocks = var.ipv6InternetCIDRblock
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "Allow HTTP traffic from the Internet"
  }
  # allow ingress of port 443
  ingress {
    cidr_blocks = [var.InternetCIDRblock]
    #ipv6_cidr_blocks = var.ipv6InternetCIDRblock
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "Allow HTTPS traffic from the Internet"
  }
  # allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "SG-ELB-TF"
    Env = "Production"
  }
} # end resource


########## Create the WebServers Security Group
resource "aws_security_group" "SG-WebServers-TF" {
  vpc_id      = aws_vpc.VPC-01.id
  name        = "SG-WebServers-TF"
  description = "Allow inbound HTTP and HTTPS traffic from LoadBalancer.  Allow SSH from LivOliv Main Office"
  # allow ingress of port 80
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.SG-ELB-TF.id}"]
    description     = "Allow HTTP from ELB Security Group"
  }
  # allow ingress of port 443
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = ["${aws_security_group.SG-ELB-TF.id}"]
    description     = "Allow HTTPS from ELB Security Group"
  }
  # allow ingress of port 22
  ingress {
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "Allow SSH from LivOliv Main Office"
  }
  # allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "SG-WebServers-TF"
    Env = "Production"
  }
} # end resource


########## Create the DBServers Security Group
resource "aws_security_group" "SG-DBServers-TF" {
  vpc_id      = aws_vpc.VPC-01.id
  name        = "SG-DBServers-TF"
  description = "Allow inbound traffic to MySQL DB server from WebServers"
  # allow ingress of port 3306
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.SG-WebServers-TF.id}"]
    description     = "Allow 3306 traffic from WebServers Security Group"
  }
  # allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "SG-DBServers-TF"
    Env = "Production"
  }
} # end resource