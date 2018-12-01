data "template_file" "solr-userdata" {
  count    = "${var.instance-count}"
  template = "${file("${path.module}/files/cloud-init.tpl")}"

  vars {
    hostname           = "${local.solr-dns-prefix}-${count.index+1}.${var.domain}"
    zookeeper_hostname = "${local.zookeeper-dns-prefix}-${count.index+1}.${var.domain}"
  }
}

resource "aws_ebs_volume" "solr-data" {
  count             = "${var.instance-count}"
  availability_zone = "${element(data.aws_subnet.subnets.*.availability_zone,count.index)}"
  size              = "${var.data-disk-size}"
  type              = "gp2"

  tags = "${merge(var.tags,
            map("Name", "${var.solr-name-prefix}-${count.index+1}-data"))}"
}

resource "aws_instance" "solr-nodes" {
  count = "${var.instance-count}"

  ami                     = "${data.aws_ami.centos7.id}"
  instance_type           = "${var.instance-type}"
  subnet_id               = "${element(var.subnet-ids, count.index)}"
  iam_instance_profile    = "${aws_iam_instance_profile.solr.name}"
  disable_api_termination = "${var.disable-api-termination}"
  vpc_security_group_ids  = ["${aws_security_group.solr.id}"]
  key_name                = "${var.keypair}"
  user_data               = "${element(data.template_file.solr-userdata.*.rendered,count.index)}"

  root_block_device {
    volume_type = "gp2"
    volume_size = "${var.root-disk-size}"
  }

  tags = "${merge(var.tags,
            map("Name", "${var.solr-name-prefix}-${count.index+1}"))}"

  lifecycle {
    ignore_changes = ["ami", "user_data"]
  }
}

resource "aws_volume_attachment" "solr-data" {
  count       = "${var.instance-count}"
  device_name = "/dev/sdf"
  volume_id   = "${element(aws_ebs_volume.solr-data.*.id, count.index)}"
  instance_id = "${element(aws_instance.solr-nodes.*.id, count.index)}"

  lifecycle {
    ignore_changes = ["volume_id", "instance_id"]
  }

  force_detach = "${var.ebs-force-dettach}"
}
