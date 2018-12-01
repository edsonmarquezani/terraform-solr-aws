#!/bin/bash
source /etc/sysconfig/terraform-vars

if [ -e /mnt/data/solr/home/solr.xml ]; then
  exit 0
fi

/usr/bin/docker run --rm --entrypoint /bin/bash -v /mnt/data/solr/home:/tmp/solr-home solr:${SOLR_VERSION} -c "cp -rpv server/solr/* /tmp/solr-home"
