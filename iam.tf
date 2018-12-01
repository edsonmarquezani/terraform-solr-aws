resource "aws_iam_role" "solr" {
  name               = "${var.solr-name-prefix}"
  assume_role_policy = "${file("${path.module}/iam/ec2-assume-role-policy.json")}"
}

resource "aws_iam_instance_profile" "solr" {
  name = "${var.solr-name-prefix}"
  role = "${aws_iam_role.solr.name}"
}
