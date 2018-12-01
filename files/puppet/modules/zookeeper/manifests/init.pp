class zookeeper {

  $zookeeper_uid = 1000
  $zookeeper_gid = 1000
  $id = regsubst($hostname, '^.*-(\d+)$','\1')

  file {
    '/mnt/data/zookeeper':
      ensure  => directory,
      owner   => "${zookeeper_uid}",
      group   => "${zookeeper_gid}",
      mode    => '0775',
      require => Mount['/mnt/data'];

    [ '/mnt/data/zookeeper/data',
      '/mnt/data/zookeeper/datalog' ]:
      ensure  => directory,
      owner   => "${zookeeper_uid}",
      group   => "${zookeeper_gid}",
      mode    => '0775',
      require => File['/mnt/data/zookeeper'];

    '/etc/systemd/system/zookeeper.service':
      ensure => present,
      source => "${::basepath}/modules/zookeeper/files/zookeeper.service",
      notify => [ Service['zookeeper.service'],
                  Exec['daemon-reload'] ];

    '/etc/sysconfig/zookeeper':
      ensure  => present,
      content => "ZOO_MY_ID=${id}",
      notify  => Service['zookeeper.service'];
  }

  service {
    'zookeeper.service':
      ensure  => running,
      enable  => true,
      require => [ File['/etc/systemd/system/zookeeper.service',
                        '/mnt/data/zookeeper']
                  ],
  }

  Exec <| title == 'daemon-reload' |> {
    before +> Service['zookeeper.service']
  }
}
