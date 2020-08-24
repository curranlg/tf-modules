########## Create S3 bucket for backups
resource "aws_s3_bucket" "S3bucket-updraft" {
  bucket = "livoliv-updraft-tf"
  acl    = "private"

  tags = {
    Name        = "LivOliv-Updraft-TF"
    Environment = "Prod"
    Usage = "Backups"
  }
}