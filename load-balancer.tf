resource "aws_lb" "solr" {
  count           = "${var.create-load-balancer}"
  name            = "${var.solr-name-prefix}"
  internal        = "${!var.load-balancer-public}"
  security_groups = ["${aws_security_group.solr.id}"]
  subnets         = ["${var.lb-subnet-ids}"]

  enable_deletion_protection = "${var.disable-api-termination}"

  tags = "${var.tags}"
}

resource "aws_lb_target_group" "solr-http" {
  count    = "${var.create-load-balancer}"
  name     = "${var.solr-name-prefix}-http"
  port     = "${local.solr-http-port}"
  protocol = "HTTP"
  vpc_id   = "${var.vpc-id}"

  health_check {
    interval            = 5
    timeout             = 4
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    path                = "/solr/"
    matcher             = "200"
  }
}

resource "aws_lb_target_group_attachment" "solr-instances-attachment" {
  count            = "${var.instance-count * var.create-load-balancer}"
  target_group_arn = "${aws_lb_target_group.solr-http.arn}"
  target_id        = "${element(aws_instance.solr-nodes.*.id, count.index)}"
  port             = "${local.solr-http-port}"
}

resource "aws_lb_listener" "solr-http" {
  count             = "${var.create-load-balancer * var.enable-http}"
  load_balancer_arn = "${aws_lb.solr.arn}"
  port              = "${local.solr-http-port}"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.solr-http.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "solr-https" {
  count             = "${var.create-load-balancer * var.load-balancer-enable-ssl}"
  load_balancer_arn = "${aws_lb.solr.arn}"
  port              = "${local.solr-https-port}"
  protocol          = "HTTPS"
  certificate_arn   = "${var.lb-acm-certificate-arn}"
  ssl_policy        = "ELBSecurityPolicy-2015-05"

  default_action {
    target_group_arn = "${aws_lb_target_group.solr-http.arn}"
    type             = "forward"
  }
}
