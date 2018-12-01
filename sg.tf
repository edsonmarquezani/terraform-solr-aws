resource "aws_security_group" "solr" {
  name        = "${var.solr-name-prefix}"
  description = "Allow Solr inbound traffic"
  vpc_id      = "${var.vpc-id}"
  tags        = "${merge(var.tags,
            map("Name", "${var.solr-name-prefix}"))}"
}

resource "aws_security_group_rule" "solr-egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.solr.id}"
}

resource "aws_security_group_rule" "solr-ingress" {
  type              = "ingress"
  from_port         = "${local.solr-http-port}"
  to_port           = "${local.solr-http-port}"
  protocol          = "tcp"
  cidr_blocks       = ["${var.allowed-networks}"]
  security_group_id = "${aws_security_group.solr.id}"
}

resource "aws_security_group_rule" "solr-https-ingress" {
  count             = "${var.load-balancer-enable-ssl}"
  type              = "ingress"
  from_port         = "${local.solr-https-port}"
  to_port           = "${local.solr-https-port}"
  protocol          = "tcp"
  cidr_blocks       = ["${var.allowed-networks}"]
  security_group_id = "${aws_security_group.solr.id}"
}

resource "aws_security_group_rule" "solr-ingress-self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  security_group_id = "${aws_security_group.solr.id}"
  self              = true
}

resource "aws_security_group_rule" "solr-ssh-ingress" {
  type              = "ingress"
  from_port         = "${local.ssh-port}"
  to_port           = "${local.ssh-port}"
  protocol          = "tcp"
  cidr_blocks       = ["${var.allowed-networks}"]
  security_group_id = "${aws_security_group.solr.id}"
}
