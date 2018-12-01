resource "aws_route53_record" "zookeeper" {
  count   = "${var.instance-count}"
  zone_id = "${data.aws_route53_zone.main-domain.zone_id}"
  name    = "${element(data.template_file.solr-userdata.*.vars.zookeeper_hostname,count.index)}"
  type    = "A"
  ttl     = "300"
  records = ["${element(aws_instance.solr-nodes.*.private_ip,count.index)}"]

  allow_overwrite = "false"
}

resource "aws_route53_record" "solr" {
  count   = "${var.instance-count}"
  zone_id = "${data.aws_route53_zone.main-domain.zone_id}"
  name    = "${element(data.template_file.solr-userdata.*.vars.hostname,count.index)}"
  type    = "A"
  ttl     = "300"
  records = ["${element(aws_instance.solr-nodes.*.private_ip,count.index)}"]

  allow_overwrite = "false"
}

resource "aws_route53_record" "solr-lb" {
  count   = "${var.create-load-balancer}"
  zone_id = "${data.aws_route53_zone.main-domain.zone_id}"
  name    = "${local.solr-dns-prefix}.${var.domain}"
  type    = "A"

  allow_overwrite = "false"

  alias {
    name                   = "${aws_lb.solr.dns_name}"
    zone_id                = "${aws_lb.solr.zone_id}"
    evaluate_target_health = false
  }
}
