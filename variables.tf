variable "subnet-ids" {
  type        = "list"
  description = "List of subnet IDs where EC2 instances will placed on"
}

variable "vpc-id" {
  type        = "string"
  description = "VPC id of subnets above"
}

variable "lb-subnet-ids" {
  type        = "list"
  description = "List of subnet IDs where load balancer will placed on (take into consideration if it's going to be public or private)"
}

variable "create-load-balancer" {
  default     = false
  description = "Whether load balancer must be created"
}

variable "load-balancer-public" {
  default     = false
  description = "Whether load balancer must be public (default is private)"
}

variable "load-balancer-enable-ssl" {
  default     = false
  description = "Whether load balancer must have SSL enabled (HTTPS)"
}

variable "lb-acm-certificate-arn" {
  default     = ""
  description = "ACM certificate to be used when SSL is enabled (optional)"
}

variable "enable-http" {
  default     = true
  description = "Whether load balancer must have HTTP enabled ('false' only makes sense when ssl is enabled)"
}

################  solr  #################

variable "solr-version" {
  default     = "7.5.0"
  description = "Solr Version"
}

variable "instance-count" {
  default     = "3"
  description = "Number of EC2 instances"
}

variable "instance-type" {
  default     = "t2.small"
  description = "EC2 instance type"
}

variable "data-disk-size" {
  default     = "15"
  description = "Size of the data disk (GB)"
}

variable "root-disk-size" {
  default     = "10"
  description = "Size of the root disk (GB)"
}

variable "solr-heap-size" {
  default     = "512M"
  description = "Size of Solr's JVM Heap (-Xms and -Xmx) (accepts any unit accepted by JVM - M, G, etc)"
}

variable "solr-name-prefix" {
  default     = "solr"
  description = "Name prefix of EC2 instances (used for Name tags and DNS names defaults)"
}

variable "solr-dns-prefix" {
  default     = ""
  description = "DNS name prefix for Solr (optional)"
}

variable "zookeeper-version" {
  default     = "3.4.13"
  description = "Zookeeper Version"
}

variable "zookeeper-heap-size" {
  default     = "1024M"
  description = "Size of Zookeepers's JVM Heap (-Xms and -Xmx) (accepts any unit accepted by JVM - M, G, etc)"
}

variable "zookeeper-dns-prefix" {
  default     = ""
  description = "DNS name prefix for Kafka (optional)"
}

############ General Settings ############

variable "tags" {
  type        = "map"
  default     = {}
  description = "Tags for EC2 instances"
}

variable "disable-api-termination" {
  default     = "true"
  description = "Whether EC2 should or not be protected from termination"
}

variable "ebs-force-dettach" {
  default     = "false"
  description = "Whether EBS disks should force-dettached when terminating EC2 instances"
}

variable "keypair" {
  type        = "string"
  description = "EC2 Keypair for SSH Access"
}

variable "domain" {
  type        = "string"
  description = "Name of the Route53 zone where DNS records will be created"
}

variable "admin-user" {
  default     = "centos"
  description = "Default administrator user of AMI used for EC2 instances"
}

variable "allowed-networks" {
  default = ["10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
  ]

  description = "List of CIDR blocks which will be allowed access to Kafka"
}
