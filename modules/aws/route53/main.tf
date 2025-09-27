########################################
# 1. Hosted Zone
########################################
resource "aws_route53_zone" "this" {
  name = local.domain_name
}

# Optional: www -> root redirect
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "www.${local.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [local.domain_name]
}


########################################
# 7. Route53 record to point domain to ALB
########################################
resource "aws_route53_record" "alb_alias" {
  zone_id = aws_route53_zone.this.zone_id
  name    = local.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = true
  }
}