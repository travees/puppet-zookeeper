# Class: zookeeper::install
#
# This module manages Zookeeper installation
#
# Parameters: None
#
# Actions: None
#
# Requires:
#
# Sample Usage: include zookeeper::install
#
class zookeeper::install(
  $ensure            = present,
  $install_method    = 'deb',
  $package_mirror    = 'http://www.mirrorservice.org/sites/ftp.apache.org/zookeeper',
  $install_dir       = '/opt/zookeeper',
  $snap_retain_count = 3,
  $cleanup_sh        = '/usr/lib/zookeeper/bin/zkCleanup.sh',
  $datastore         = '/var/lib/zookeeper',
  $user              = 'zookeeper',
) {

  if ($install_method == 'deb') {
    package { ['zookeeper']:
      ensure => $ensure
    }

    package { ['zookeeperd']: #init.d scripts for zookeeper
      ensure  => $ensure,
      require => Package['zookeeper']
    }
  } else {
    package { ['zookeeper','zookeeperd']:
      ensure => absent
    }

    file { $install_dir:
      ensure => directory
    }

    exec { 'download-zk-package':
      command => "/usr/bin/wget -O /tmp/zookeeper-${ensure}.tar.gz ${package_mirror}/zookeeper-${ensure}/zookeeper-${ensure}.tar.gz",
      creates => "/tmp/zookeeper-${ensure}.tar.gz"
    }

    exec { 'install-zk-package':
      command => "/bin/tar -xvzf /tmp/zookeeper-${ensure}.tar.gz -C ${install_dir}",
      creates => $install_dir,
      require => [
        Exec['download-zk-package'],
        File[$install_dir]
      ]
    }
  }

  # if !$cleanup_count, then ensure this cron is absent.
  if ($snap_retain_count > 0 and $ensure != 'absent') {
    ensure_packages(['cron'])

    cron { 'zookeeper-cleanup':
        ensure  => present,
        command => "${cleanup_sh} ${datastore} ${snap_retain_count}",
        hour    => 2,
        minute  => 42,
        user    => $user,
        require => Package['zookeeper'],
    }
  }
}
