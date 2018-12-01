# Overview
This Terraform module deploys (with help of [*Puppet*](https://puppet.com/docs/puppet/6.0/puppet_index.html)) an [*Apache Solr*](http://lucene.apache.org/solr/) cluster (*cloud* mode) on *EC2* instances.

It deploys the following resources on AWS:

- EC2 instances (with its own security group, IAM role and EBS data disk)
- Load Balancer (optional)
- DNS records
  - A records for every EC2
  - A record for balancer (if present)

# Requirements
- Terraform >= 0.11.7 (it's likely it's going to work with older version as well, but I haven't tested it, so I can't guarantee anything)
- AWS credentials on environment (see `aws configure` command or alternatives)
- *Route53* domain, *EC2* network infra-structure (VPC and subnets) already existent on AWS
- SSH client (along with the private key of keypair chosen for EC2)

**In order run Puppet, after the instances creation, Terraform needs to be able to connect via SSH on them.** So make sure you have a private key loaded (`~/.ssh/id_rsa` or via `ssh-agent`) and that it matches the public key set on `keypair` module attribute, as well as network connectivity to private VPC addresses (use a bastion host inside VPC if needed).

Regarding credentials, you may, alternatively, define them directly on Terraform, although it's not recommended. See [***AWS***](https://www.terraform.io/docs/providers/aws/index.html) providers documentation.

# How to use
It's strongly recommended that you fork it, and modify it according to your needs. But, if for any reason you don't want to, the easiest way to use it is setting this repository as a module source, and parameterize it according to your needs, like below.

```hcl
# You must declare the provider (module does not do it)
provider "aws" {
  region = "us-east-1"
}

locals {
  subnets = [
    "private-zone-a",
    "private-zone-b",
  ]
}

# Data sources for VPC and Subnets
data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["productive"]
  }
}

data "aws_subnet" "subnets" {
  count = "${length(local.subnets)}"

  filter {
    name   = "tag:Name"
    values = ["${local.subnets[count.index]}"]
  }
}

module "solr" {

  # Change the repo branch if needed and NEVER USE MASTER
  # (as it may change and break your setup)
  source = "github.com/edsonmarquezani/terraform-solr-aws?ref=1.0"

  # Required attributes
  domain                  = "foo.bar"
  vpc-id                  = "${data.aws_vpc.vpc.id}"
  subnet-ids              = ["${data.aws_subnet.subnets.*.id}"]
  lb-subnet-ids           = ["${data.aws_subnet.subnets.*.id}"]
  keypair                 = "my-key"

  # Optional, yet important, parameters (you'll probably want to set it explictly,
  # instead of relying on defaults)
  instance-type    = "m4.large"
  instance-count   = "3"
  solr-name-prefix = "my-solr-cloud"
  solr-version     = "7.5.0"
  solr-heap-size   = "4G"
  data-disk-size   = "100G"

  # Load Balancer (if wanted)
  create-load-balancer     = true
  load-balancer-public     = false
  load-balancer-enable-ssl = true
  lb-acm-certificate-arn   = "<arn_for_amazon_certificate_manager>"
}

output "hostnames" {
  value = ["${module.solr.solr-hostnames}"]
}

output "balancer-endpoint" {
  value = "${module.solr.solr-balancer-endpoint}"
}
```

```shell
$ terraform init
$ terraform apply
```

If successfull, Terraform will show information like bellow.
```
Apply complete! Resources: 38 added, 0 changed, 0 destroyed.

Outputs:

balancer-endpoint = https://my-solr-cloud-1.foo.bar:8983/solr/
hostnames = [
    my-solr-cloud-1.foo.bar,
    my-solr-cloud-2.foo.bar,
    my-solr-cloud-3.foo.bar
]
```

**A complete list of module options can be viewed in `variables.tf` file.**

# Setup details

AWS resources are created by Terraform, then Puppet is run in standalone mode through ssh connection in each instance, doing all the additional setup.

Each instance gets **Solr** and **Zookeeper** installed. The setup is based on Systemd Units and Docker containers. Both applications are installed as [services units](https://www.freedesktop.org/software/systemd/man/systemd.service.html), but instead of installing software on host directly, services create/start/stop/delete containers. All data is persisted on external disks, presented to containers as Docker volumes, so they can be destroyed and recreated at any time, securely.

Once run, Terraform won't run the commands again, even if the Puppet contents changes. There are two reason for this:
- [Terraform's null_resource](https://www.terraform.io/docs/provisioners/null_resource.html), used to run commands, don't detect changes and don't run more than once;
- Terraform are not aware of Puppet files, it just uploads them and run Puppet agent to apply.
So, if you need/want to run this part of the automation again, it will be necessary, first, to [`taint`](https://www.terraform.io/docs/commands/taint.html) the resources, and then apply it again.
```
terraform taint -module solr null_resource.puppet-apply.0
//[...] repeat if for each instance
terraform taint -module solr null_resource.puppet-apply.2

terraform apply
```

# Scaling the cluster

To scale the cluster, just increase the `instance-count` attribute and apply it. The additional nodes will be created and joined to the cluster. **Off course, Solr tasks (like raising replica count, reallocation of shards, etc) is up to you and not managed by this module.**

# FAQ

Before you even ask me, I would like to make it clear.

### Why did you choose Puppet instead of Ansible?
Me and Puppet, we are old friends. I really like it, and I know it better than others tools, like Ansible. The baseline of this automation was done sometime ago, and then reused in a lot of different setups. I found this standalone way of using Puppet to work very well and I was happy enough with it, so I didn't feel any need to change it.

## Why to use CentOS?
Again, when I stablished the baseline of this kind of automation, I choose CentOS for reasons related to the project I was working on at that time. Then, Puppet code was written around this and I never felt it was really necessary to change it (plus couldn't afford the time for it, to be honest.) Since we run everything in containers, host operating system doesn't really matter too much.

## What is the username to connect via SSH?
`centos`

## Why to use LVM?
I thought it wouldn't hurt to create data disks with LVM, although nowadays, specially on cloud, the mindset is to destroy and recreate resources instead of be managing it and growing disks, etc. But, once we are still talking about IaaS here, using LVM sounded like a good practice and could save some lifes in the future. If not, won't represent any harm, anyway.

## Why to deploy applications on virtual machines as containers, and not on containers platforms (like Kubernetes), anyway?
Well, that's a polemic topic. But, I feel some applications, specially database-like ones, as *Elasticsearch*, *Solr*, etc, aren't so that well-suited for *Kubernetes* and similar platforms. Off course *Kubernetes* support stateful applications, even having a specific resource for it ([*StatefulSets*](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/)). I use and like it.
Even though, there are some applications out there - *Apache's Zookeeper* and *Kafka* are some of them - that don't support this model of deployment very well, because of network addresses dependencies issues, and other characteristics of software born in an older world, let's say, less dynamic. Even despite this, some people may just not feel confortable yet to run this kind of application on *Kubernetes*. And off course, anyone with a AWS account can create some EC2 instances, but not everyone has a *Kubernetes* (or similar) cluster available to use.
