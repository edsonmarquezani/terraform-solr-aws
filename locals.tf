data "template_file" "zoo-servers" {
  count = "${var.instance-count}"

  vars {
    part = "server.${count.index+1}=${element(data.template_file.solr-userdata.*.vars.zookeeper_hostname,count.index)}:2888:3888"
  }
}

locals {
  setup-files-path     = "/tmp"
  zookeeper-connect    = "${join(",", formatlist("%s:2181",data.template_file.solr-userdata.*.vars.zookeeper_hostname))}"
  zoo-servers          = "${join(" ", data.template_file.zoo-servers.*.vars.part)}"
  solr-dns-prefix      = "${var.solr-dns-prefix == "" ? "${var.solr-name-prefix}" : var.solr-dns-prefix}"
  solr-http-port       = 8983
  solr-https-port      = 8984
  zookeeper-dns-prefix = "${local.solr-dns-prefix}-zookeeper"
  zookeeper-ports      = [2181, 2888, 3888]
  ssh-port             = 22
}
