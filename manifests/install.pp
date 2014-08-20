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
  $ensure            = $zookeeper::ensure,
  $install_method    = $zookeeper::install_method,
  $package_mirror    = $zookeeper::package_mirror,
  $install_dir       = $zookeeper::install_dir,
  $snap_retain_count = $zookeeper::snap_retain_count,
  $cleanup_sh        = $zookeeper::cleanup_sh,
  $datastore         = $zookeeper::datastore,
  $user              = $zookeeper::user
) {

  if ($install_method == 'deb') {
    package { ['zookeeper']:
      ensure => $ensure
    }

    package { ['zookeeperd']:
      ensure  => $ensure,
      require => Package['zookeeper']
    }
  } else {
    package { ['zookeeper','zookeeperd']:
      ensure => absent
    }

    file { $install_dir:
      ensure => link,
      target => "${install_dir}-${ensure}"
    }

    exec { 'download-zk-package':
      command => "/usr/bin/wget -O /tmp/zookeeper-${ensure}.tar.gz ${package_mirror}/zookeeper-${ensure}/zookeeper-${ensure}.tar.gz",
      creates => "/tmp/zookeeper-${ensure}.tar.gz"
    }

    exec { 'install-zk-package':
      command => "/bin/tar -xvzf /tmp/zookeeper-${ensure}.tar.gz -C /opt",
      creates => "${install_dir}-${ensure}/zookeeper-${ensure}.jar",
      require => [
        Exec['download-zk-package']
      ]
    }
    
    file { "${install_dir}-${ensure}":
      ensure  => directory,
      recurse => true,
      owner   => 'zookeeper',
      group   => 'zookeeper'
    }
  }

  group { 'zookeeper':
    ensure => present,
    system => true
  }

  user { 'zookeeper':
    ensure => present,
    groups => ['zookeeper'],
    system => true,
    home   => $install_dir
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
