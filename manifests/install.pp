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
  $install_method    = 'package',
  $mirror_url        = 'http://mirror.cogentco.com/pub/apache',
  $archive_checksum  = {},
  $install_dir       = '/opt/zookeeper',
  $package_dir       = '/var/tmp/zookeeper',
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
    $clean = $manual_clean
    $repo_source = is_hash($repo) ? {
          true  => 'custom',
          false =>  $repo,
    }
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
  } elsif ($install_method == 'archive') {
    include '::archive'

    $basefilename = "zookeeper-${ensure}.tar.gz"
    $package_url = "${mirror_url}/zookeeper/zookeeper-${ensure}/${basefilename}"
    $extract_path = "${install_dir}-${ensure}"

    if ($manual_clean == undef) {
      $clean = versioncmp($ensure, '3.4') ? {
        '-1'    => true,
        default => false,
      }
    } else {
      $clean = $manual_clean
    }

    package { ['zookeeper','zookeeperd']:
      ensure => absent
    }

    file { $install_dir:
      ensure => link,
      target => $extract_path
    }

    file { $package_dir:
      ensure  => directory,
      owner   => 'zookeeper',
      group   => 'zookeeper',
      require => [
        Group['zookeeper'],
        User['zookeeper'],
      ],
    }

    file { $extract_path:
      ensure  => directory,
      owner   => 'zookeeper',
      group   => 'zookeeper',
      require => [
        Group['zookeeper'],
        User['zookeeper'],
      ],
    }

    archive { "${package_dir}/${basefilename}":
      ensure          => present,
      extract         => true,
      extract_command => 'tar xfz %s --strip-components=1',
      extract_path    => $extract_path,
      source          => $package_url,
      checksum        => $archive_checksum['hash'],
      checksum_type   => $archive_checksum['type'],
      creates         => "${extract_path}/conf",
      cleanup         => true,
      user            => 'zookeeper',
      group           => 'zookeeper',
      require         => [
        File[$package_dir],
        File[$install_dir],
        Group['zookeeper'],
        User['zookeeper'],
      ],
    }
  } else {
    fail("You must specify a valid install method for zookeeper")
  }

  file { '/usr/local/bin/znode_exists.sh':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/zookeeper/znode_exists.sh',
    require => File['/usr/local/bin'],
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
    manual_clean      => $clean,
    require           => Anchor['zookeeper::install::end'],
  }

}
