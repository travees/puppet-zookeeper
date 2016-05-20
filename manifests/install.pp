# Class: zookeeper::install
#
# This module manages Zookeeper installation
#
# Parameters: None
#
# Actions: None
#
#
# Should not be included directly
#
class zookeeper::install(
  $install_method    = $zookeeper::install_method,
  $download_url      = 'http://mirror.cogentco.com/pub/apache/zookeeper',
  $install_dir       = '/opt/zookeeper',
  $ensure            = present,
  $snap_retain_count = 3,
  $cleanup_sh        = '/usr/lib/zookeeper/bin/zkCleanup.sh',
  $datastore         = '/var/lib/zookeeper',
  $user              = 'zookeeper',
  $group             = 'zookeeper',
  $ensure_account    = present,
  $service_provider  = 'init.d',
  $ensure_cron       = true,
  $service_package   = 'zookeeperd',
  $packages          = ['zookeeper'],
  $cdhver            = undef,
  $install_java      = false,
  $java_package      = undef,
  $repo              = undef,
  $manual_clean      = undef,
) {
  anchor { 'zookeeper::install::begin': }
  anchor { 'zookeeper::install::end': }

  if ($install_method == 'package') {
    case $::osfamily {
      'Debian': {
        class { 'zookeeper::os::debian':
          ensure           => $ensure,
          service_provider => $service_provider,
          service_package  => $service_package,
          packages         => $packages,
          before           => Anchor['zookeeper::install::end'],
          require          => Anchor['zookeeper::install::begin'],
          install_java     => $install_java,
          java_package     => $java_package
        }
      }
      'RedHat': {
        class { 'zookeeper::repo':
          source => $repo_source,
          cdhver => $cdhver,
          config => $repo
        }

        class { 'zookeeper::os::redhat':
          ensure       => $ensure,
          packages     => $packages,
          require      => Anchor['zookeeper::install::begin'],
          before       => Anchor['zookeeper::install::end'],
          install_java => $install_java,
          java_package => $java_package
        }
      }
      default: {
        fail("Module '${module_name}' is not supported on OS: '${::operatingsystem}', family: '${::osfamily}'")
      }
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


  class { 'zookeeper::post_install':
    ensure            => $ensure,
    ensure_account    => $ensure_account,
    ensure_cron       => $ensure_cron,
    user              => $user,
    group             => $group,
    datastore         => $datastore,
    snap_retain_count => $snap_retain_count,
    cleanup_sh        => $cleanup_sh,
    manual_clean      => $manual_clean,
    require           => Anchor['zookeeper::install::end'],
  }

}
