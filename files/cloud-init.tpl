#cloud-config

fqdn: ${hostname}

write_files:

  - path: /etc/yum.repos.d/puppetlabs-pc1.repo
    permissions: '0644'
    content: |
      [puppetlabs-pc1]
      name=Puppet Labs PC1 Repository el 7 - $$basearch
      baseurl=http://yum.puppetlabs.com/el/7/PC1/$$basearch
      enabled=1
      gpgcheck=0

  - path: /opt/puppetlabs/facter/facts.d/basepath.sh
    permissions: '0755'
    content: |
      #!/bin/bash
      echo "basepath=/tmp/puppet"

packages:
  - puppet-agent
  - lvm2

runcmd:
  - hostname ${hostname}
