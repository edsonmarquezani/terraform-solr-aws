class common::docker {

  class {
    'docker':
      socket_bind  => 'unix:///var/run/docker.sock',
      docker_users => [ 'centos' ],
      log_driver   => 'journald',
  }

  file {
    '/etc/systemd/system/docker.service.d/30-increase-ulimit.conf':
      ensure  => present,
      source  => "${::basepath}/modules/common/files/30-increase-ulimit.conf",
      require => File['/etc/systemd/system/docker.service.d'],
      notify  => Service['docker'];

    '/root/.docker':
      ensure => directory;
  }

}
