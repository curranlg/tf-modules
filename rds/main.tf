########## Explicitly state which provider to use
provider "aws" {}

########## Create DB Subnet Group containing the LivOliv VPC private subnets
resource "aws_db_subnet_group" "rds-sng-01" {
  name        = "rds-sng-livoliv-private-tf"
  description = "Private subnets in LivOliv VPC - TF"
  subnet_ids  = ["${aws_subnet.Private-2a.id}", "${aws_subnet.Private-2b.id}"]
  tags = {
    Name = "LivOliv DB subnet group - TF"
  }
}
# End of Resource

########## Create the RDS MySQL DB instance
resource "aws_db_instance" "rds-mysql-01" {
  identifier                  = "livoliv-mysql8x-tf"
  allocated_storage           = 20
  storage_type                = "gp2"
  engine                      = "mysql"
  engine_version              = "8.0.17"
  availability_zone           = var.availabilityZoneA
  instance_class              = "db.t2.micro"
  name                        = "bitnami_wordpress"
  username                    = var.dbusername
  password                    = var.dbuserpass
  parameter_group_name        = "default.mysql8.0"
  db_subnet_group_name        = aws_db_subnet_group.rds-sng-01.name
  vpc_security_group_ids      = [aws_security_group.SG-DBServers-TF.id]
  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true
  backup_retention_period     = 35
  backup_window               = "22:00-23:00"
  maintenance_window          = "Sat:00:00-Sat:03:00"
  multi_az                    = false
  skip_final_snapshot         = true
  publicly_accessible         = false
}
# End of Resource


