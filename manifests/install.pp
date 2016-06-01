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

  if ($install_method == 'package') {

    include '::zookeeper::install::package'
    $clean = $manual_clean

  } else {

    include '::zookeeper::install::archive'
    if ($manual_clean == undef) {
      $clean = versioncmp($ensure, '3.4') ? {
        '-1'    => true,
        default => false,
      }
    } else {
      $clean = $manual_clean
    }

  }

  anchor { 'zookeeper::install::end': }

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
