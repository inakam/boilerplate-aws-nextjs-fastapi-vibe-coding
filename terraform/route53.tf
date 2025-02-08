data "aws_route53_zone" "inakam_net" {
  name = var.root_domain
}

# サブドメインの各種設定
locals {
  subdomains = {
    "static"   = "static.${data.aws_route53_zone.inakam_net.name}",
    "backend"  = "backend.${data.aws_route53_zone.inakam_net.name}",
    "frontend" = "frontend.${data.aws_route53_zone.inakam_net.name}",
  }
}

# 証明書の作成
resource "aws_acm_certificate" "inakam_net" {
  provider                  = aws.virginia
  domain_name               = data.aws_route53_zone.inakam_net.name
  subject_alternative_names = [format("*.%s", data.aws_route53_zone.inakam_net.name)]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "certificate" {
  for_each = tomap({
    for dvo in aws_acm_certificate.inakam_net.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  })

  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.inakam_net.id
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "cert" {
  provider                = aws.virginia
  certificate_arn         = aws_acm_certificate.inakam_net.arn
  validation_record_fqdns = [for record in aws_route53_record.certificate : record.fqdn]
}

# S3の接続設定
resource "aws_route53_record" "static" {
  zone_id = data.aws_route53_zone.inakam_net.zone_id
  name    = local.subdomains["static"]
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.static.domain_name
    zone_id                = aws_cloudfront_distribution.static.hosted_zone_id
    evaluate_target_health = false
  }
}


# backendの接続設定
resource "aws_route53_record" "backend" {
  zone_id = data.aws_route53_zone.inakam_net.zone_id
  name    = local.subdomains["backend"]
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.backend.domain_name
    zone_id                = aws_cloudfront_distribution.backend.hosted_zone_id
    evaluate_target_health = false
  }
}


# フロントエンドの接続設定
resource "aws_route53_record" "frontend" {
  zone_id = data.aws_route53_zone.inakam_net.zone_id
  name    = local.subdomains["frontend"]
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.frontend.domain_name
    zone_id                = aws_cloudfront_distribution.frontend.hosted_zone_id
    evaluate_target_health = false
  }
}
