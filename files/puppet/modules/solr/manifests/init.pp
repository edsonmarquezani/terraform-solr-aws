class solr {

  $solr_uid = 8983
  $solr_gid = 8983

  group {
    'solr':
      ensure => present,
      gid    => "${solr_gid}",
  }

  user {
    'solr':
      ensure  => present,
      uid     => "${solr_uid}",
      gid     => "${solr_gid}",
      require => Group['solr'],
  }

  file {
    ['/mnt/data/solr',
     '/mnt/data/logs' ]:
      ensure  => directory,
      owner   => "${solr_uid}",
      group   => "${solr_gid}",
      mode    => '0775',
      require => Mount['/mnt/data'];

    ['/mnt/data/solr/data',
     '/mnt/data/solr/home' ]:
      ensure  => directory,
      owner   => "${solr_uid}",
      group   => "${solr_gid}",
      mode    => '0775',
      require => File['/mnt/data/solr'];

    '/etc/systemd/system/solr.service':
      ensure  => present,
      source  => "${::basepath}/modules/solr/files/solr.service",
      notify  => [ Service['solr.service'],
                    Exec['daemon-reload'] ];

    '/usr/local/bin/solr-setup-config.sh':
      ensure  => present,
      source  => "${::basepath}/modules/solr/files/solr-setup-config.sh",
      mode    => '0755'

  }

  exec {
    'install-solr-confs':
      command => '/usr/local/bin/solr-setup-config.sh',
      require => [ File['/mnt/data/solr/home',
                        '/usr/local/bin/solr-setup-config.sh'],
                   Service['docker']
                 ];
  }

  service {
    'solr.service':
      ensure  => running,
      enable  => true,
      require => [ File['/etc/systemd/system/solr.service',
                        '/mnt/data/solr/data',
                        '/mnt/data/solr/home',
                        '/usr/local/bin/solr-setup-config.sh'],
                   Exec['install-solr-confs']
                 ],
  }

  Exec <| title == 'daemon-reload' |> {
    before +> Service['solr.service']
  }
}
