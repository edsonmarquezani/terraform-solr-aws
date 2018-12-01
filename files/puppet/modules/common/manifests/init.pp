class common {

  include common::docker

  package {
    'lvm2':
      ensure => present
  }

  class {
    'selinux':
      mode => 'disabled';

    'lvm':
      manage_pkg => false,
      volume_groups => {
        'vg_data' => {
          physical_volumes => [ "/dev/${keys($::disks)[1]}" ],
          logical_volumes => {
            'data' => {
              'fs_type'           => 'ext4',
              'mountpath'         => '/mnt/data',
              'mountpath_require' => true
            }
          }
        }
      },
      require => Package['lvm2']
  }

  file {
    '/mnt/data':
      ensure => directory;
  }

  @exec {
    'daemon-reload':
      command     => '/bin/systemctl daemon-reload',
      refreshonly => true,
  }

  @sysctl {
    'vm.max_map_count':
      ensure => present,
      value  => '262144',
      notify => Service['docker'],
  }

}
