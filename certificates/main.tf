########## Explicitly state which provider to use
provider "aws" {
  alias = "dns"
}

########## Grab reference to existing livoliv.com and livoliv.co.uk R53 Hosted Zones
data "aws_route53_zone" "dnszone1" {
  provider = aws.dns
  name         = "livoliv.com."
  #private_zone = true
}

data "aws_route53_zone" "dnszone2" {
  provider = aws.dns
  name         = "livoliv.co.uk."
  #private_zone = true
}

########## Add A record for rmt.livoliv.com to EC2 instance EIP
#resource "aws_route53_record" "dns_a" {
#  provider = aws.dns
#  zone_id = data.aws_route53_zone.dnszone1.zone_id
#  name    = "rmt.${data.aws_route53_zone.dnszone1.name}"
#  type    = "A"
#  ttl     = "300"
#  records = ["10.0.0.1"]
#}

##################
# ACM certificate
##################

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 2.0"

  zone_id = data.aws_route53_zone.dnszone1.zone_id

  domain_name = "www.livoliv.com"
  subject_alternative_names = [
      "livoliv.com",
      "www.livoliv.co.uk",
      "livoliv.co.uk"
  ]
  
  wait_for_validation = false
}