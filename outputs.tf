locals {
  solr-lb-protocol = "${var.load-balancer-enable-ssl ? "https" : "http"}"
  solr-lb-port     = "${var.load-balancer-enable-ssl ? local.solr-https-port : local.solr-http-port}"
}

output "zookeeper-hostnames" {
  value = ["${aws_route53_record.zookeeper.*.fqdn}"]
}

output "solr-hostnames" {
  value = ["${aws_route53_record.solr.*.fqdn}"]
}

output "solr-instance-ids" {
  value = ["${aws_instance.solr-nodes.*.id}"]
}

output "solr-endpoints" {
  value = "${formatlist("http://%s:%s/solr/",aws_route53_record.solr.*.fqdn,local.solr-http-port)}"
}

output "solr-balancer-endpoint" {
  value = "${ var.create-load-balancer ? "${local.solr-lb-protocol}://${aws_route53_record.solr-lb.0.fqdn}:${local.solr-lb-port}/solr/" : "null" }"
}

output "solr-security-group-id" {
  value = "${aws_security_group.solr.id}"
}

output "solr-http-port" {
  value = "${local.solr-http-port}"
}
