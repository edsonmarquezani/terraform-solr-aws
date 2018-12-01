#!/bin/bash

yum install -y puppet-agent
/opt/puppetlabs/puppet/bin/gem install r10k -v 2.6.5
test -e /usr/local/bin/facter || ln -s /opt/puppetlabs/bin/facter /usr/local/bin/facter
test -e /usr/local/bin/puppet || ln -s /opt/puppetlabs/bin/puppet /usr/local/bin/puppet
test -e /usr/local/bin/r10k || ln -s /opt/puppetlabs/puppet/bin/r10k /usr/local/bin/r10k
