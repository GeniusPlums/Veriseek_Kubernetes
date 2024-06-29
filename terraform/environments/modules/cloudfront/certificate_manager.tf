#------------------------------------------------------------------------------
# SSL/TLS certs issued in the AWS region for ALB
#------------------------------------------------------------------------------
provider "aws" {
  alias  = "environment_region"
  region = var.aws_region
}

#------------------------------------------------------------------------------
# SSL/TLS certs issued in us-east-1 for Cloudfront
#------------------------------------------------------------------------------

module "acm_environment_domain" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  providers = {
    aws = aws.us-east-1
  }

  domain_name       = var.environment_domain
  zone_id           = data.aws_route53_zone.environment_domain.id
  validation_method = "DNS"


  subject_alternative_names = [
    "*.${var.environment_domain}",
  ]

  wait_for_validation = true

  # adding the Usage tag as a way to differentiate this cert from the one created by
  # the eks clb ingress, of which we have no control.
  tags = merge(
    local.tags,
    { Usage = "Cloudfront" },
    {
      "cookiecutter/resource/source"  = "terraform-aws-modules/acm/aws"
      "cookiecutter/resource/version" = "5.0"
    }
  )

}

