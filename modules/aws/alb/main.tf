# ===================================
# 🏗️  Application Load Balancer (ALB)
# ===================================

resource "aws_lb" "this" {
  name               = local.name
  internal           = false                        # Controls if the ALB is public or internal
  load_balancer_type = "application"                # ALB operates at Layer 7 (HTTP/HTTPS)
  security_groups    = [aws_security_group.this.id] # Attach associated security group
  subnets            = var.subnet_ids               # Deploy ALB across specified subnets

  enable_cross_zone_load_balancing = true

  tags = {
    Name = local.name
  }
}

# ====================================
# 🎯 Target Groups (for ALB Listeners)
# ====================================

resource "aws_lb_target_group" "blue_client" {
  name                          = "blue-client-${local.name}"
  port                          = 80
  protocol                      = "HTTP" # Only HTTP or HTTPS for ALB
  vpc_id                        = var.vpc_id
  target_type                   = "ip" # instance, ip, or lambda
  load_balancing_algorithm_type = "round_robin"

  # Optional attributes
  connection_termination = false

  # Optional health check block
  health_check {
    enabled             = true
    interval            = 30  # how often LB checks
    path                = "/" # must match your container/EC2 health endpoint
    port                = "traffic-port"
    healthy_threshold   = 3     # how many successes to mark healthy
    unhealthy_threshold = 2     # how many fails to mark unhealthy
    timeout             = 5     # how long to wait for response
    matcher             = "200" # (for ALB/HTTP checks)
  }

  tags = {
    Name = "blue-client-${local.name}"
  }
}

resource "aws_lb_target_group" "green_client" {
  name                          = "green-client-${local.name}"
  port                          = 80
  protocol                      = "HTTP" # Only HTTP or HTTPS for ALB
  vpc_id                        = var.vpc_id
  target_type                   = "ip" # instance, ip, or lambda
  load_balancing_algorithm_type = "round_robin"

  # Optional attributes
  connection_termination = false

  # Optional health check block
  health_check {
    enabled             = true
    interval            = 30  # how often LB checks
    path                = "/" # must match your container/EC2 health endpoint
    port                = "traffic-port"
    healthy_threshold   = 3     # how many successes to mark healthy
    unhealthy_threshold = 2     # how many fails to mark unhealthy
    timeout             = 5     # how long to wait for response
    matcher             = "200" # (for ALB/HTTP checks)
  }

  tags = {
    Name = "green-client-${local.name}"
  }
}

resource "aws_lb_target_group" "blue_api" {
  name                          = "blue-api-${local.name}"
  port                          = 80
  protocol                      = "HTTP" # Only HTTP or HTTPS for ALB
  vpc_id                        = var.vpc_id
  target_type                   = "ip" # instance, ip, or lambda
  load_balancing_algorithm_type = "round_robin"

  # Optional attributes
  connection_termination = false

  # Optional health check block
  health_check {
    enabled             = true
    interval            = 30  # how often LB checks
    path                = "/" # must match your container/EC2 health endpoint
    port                = "traffic-port"
    healthy_threshold   = 3     # how many successes to mark healthy
    unhealthy_threshold = 2     # how many fails to mark unhealthy
    timeout             = 5     # how long to wait for response
    matcher             = "200" # (for ALB/HTTP checks)
  }

  tags = {
    Name = "blue-api-${local.name}"
  }
}

resource "aws_lb_target_group" "green_api" {
  name                          = "green-api-${local.name}"
  port                          = 80
  protocol                      = "HTTP" # Only HTTP or HTTPS for ALB
  vpc_id                        = var.vpc_id
  target_type                   = "ip" # instance, ip, or lambda
  load_balancing_algorithm_type = "round_robin"

  # Optional attributes
  connection_termination = false

  # Optional health check block
  health_check {
    enabled             = true
    interval            = 30  # how often LB checks
    path                = "/" # must match your container/EC2 health endpoint
    port                = "traffic-port"
    healthy_threshold   = 3     # how many successes to mark healthy
    unhealthy_threshold = 2     # how many fails to mark unhealthy
    timeout             = 5     # how long to wait for response
    matcher             = "200" # (for ALB/HTTP checks)
  }

  tags = {
    Name = "green-api-${local.name}"
  }
}

# ================================
# 🎧 ALB Listeners (Port 80 / 443)
# ================================

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443     # Usually 80 or 443
  protocol          = "HTTPS" # HTTP or HTTPS
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  # Optional for HTTPS
  certificate_arn = aws_acm_certificate.this.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue_client.arn
  }

  depends_on = [
    aws_acm_certificate_validation.this
  ]

  tags = {
    Name = "https-${local.name}"
  }
}

# HTTP listener -> Redirect to HTTPS
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = {
    Name = "http-${local.name}"
  }
}

# ==========================================
# 📜 ALB Listener Rules (Path-based Routing)
# ==========================================

resource "aws_lb_listener_rule" "api_https" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 1

  # Forward requests to matching target group
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue_api.arn
  }

  # Match based on path pattern
  condition {
    path_pattern {
      values = ["/api"]
    }
  }

  tags = {
    Name = "api-https-${local.name}"
  }
}

# =========================
# 🔐 Security Group for ALB
# =========================

resource "aws_security_group" "this" {
  name   = local.name
  vpc_id = var.vpc_id

  tags = {
    Name = local.name
  }
}

# ========================================
# 🌐 Ingress Rules for ALB (Public Access)
# ========================================

# Allow HTTPS (port 443) from anywhere — optional
resource "aws_security_group_rule" "public_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow HTTPS"
  security_group_id = aws_security_group.this.id
}

# ======================
# 📤 Egress Rule for ALB
# ======================

# Allow all outbound traffic
resource "aws_security_group_rule" "egress" {
  description       = "Allow all outbound traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

# ===================================
# 2. ACM Certificate (DNS validation)
# ===================================
resource "aws_acm_certificate" "this" {
  domain_name       = local.domain_name
  validation_method = "DNS"

  subject_alternative_names = [
    "www.${local.domain_name}"
  ]

  tags = {
    Name = "${local.name}-cf"
  }
}

# =================================
# 3. DNS records for ACM validation
# =================================
resource "aws_route53_record" "cert_records" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => dvo
  }

  zone_id = var.hostedzone_id
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  records = [each.value.resource_record_value]
  ttl     = 60
}

# =============================
# 4. ACM Certificate Validation
# =============================
resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_records : record.fqdn]
}

# ========================================
# 7. Route53 record to point domain to ALB
# ========================================
resource "aws_route53_record" "alb_alias" {
  zone_id = var.hostedzone_id
  name    = local.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = true
  }
}