# Class: zookeeper
#
# This module manages zookeeper
#
# Parameters:
#   id
#   user
#   group
#   log_dir
#
# Sample Usage:
#
#   class { 'zookeeper': }
#
class zookeeper(
  $id                      = $zookeeper::params::id,
  $datastore               = $zookeeper::params::datastore,
  $client_ip               = $zookeeper::params::client_ip,
  $client_port             = $zookeeper::params::client_port,
  $log_dir                 = $zookeeper::params::log_dir,
  $cfg_dir                 = $zookeeper::params::cfg_dir,
  $user                    = $zookeeper::params::user,
  $group                   = $zookeeper::params::group,
  $java_bin                = $zookeeper::params::java_bin,
  $java_opts               = $zookeeper::params::java_opts,
  $pid_dir                 = $zookeeper::params::pid_dir,
  $pid_file                = $zookeeper::params::pid_file,
  $zoo_main                = $zookeeper::params::zoo_main,
  $lo4j_prop               = $zookeeper::params::log4j_prop,
  $cleanup_sh              = $zookeeper::params::cleanup_sh,
  $servers                 = $zookeeper::params::servers,
  $ensure                  = $zookeeper::params::ensure,
  $snap_count              = $zookeeper::params::snap_count,
  $snap_retain_count       = $zookeeper::params::snap_retain_count,
  $purge_interval          = $zookeeper::params::purge_interval,
  $rollingfile_threshold   = $zookeeper::params::rollingfile_threshold,
  $tracefile_threshold     = $zookeeper::params::tracefile_threshold,
  $max_allowed_connections = $zookeeper::params::max_allowed_connections,
  $peer_type               = $zookeeper::params::peer_type,
  $install_method          = $zookeeper::params::install_type,
  $package_mirror          = $zookeeper::params::package_mirror,
  $install_dir             = $zookeeper::params::install_dir,
  $exhibitor_managed       = $zookeeper::params::exhibitor_managed
) inherits zookeeper::params {

  anchor { 'zookeeper::start': }->
  class { 'zookeeper::install':
    ensure            => $ensure,
    install_method    => $install_method,
    package_mirror    => $package_mirror,
    install_dir       => $install_dir,
    snap_retain_count => $snap_retain_count,
    datastore         => $datastore,
    user              => $user,
    cleanup_sh        => $cleanup_sh,
  }->
  class { 'zookeeper::config':
    id                      => $id,
    datastore               => $datastore,
    client_ip               => $client_ip,
    client_port             => $client_port,
    log_dir                 => $log_dir,
    cfg_dir                 => $cfg_dir,
    user                    => $user,
    group                   => $group,
    java_bin                => $java_bin,
    java_opts               => $java_opts,
    pid_dir                 => $pid_dir,
    zoo_main                => $zoo_main,
    log4j_prop              => $log4j_prop,
    servers                 => $servers,
    snap_count              => $snap_count,
    snap_retain_count       => $snap_retain_count,
    purge_interval          => $purge_interval,
    rollingfile_threshold   => $rollingfile_threshold,
    tracefile_threshold     => $tracefile_threshold,
    max_allowed_connections => $max_allowed_connections,
    peer_type               => $peer_type,
    exhibitor_managed       => $exhibitor_managed
  }->
  class { 'zookeeper::service':
    cfg_dir => $cfg_dir,
  }
  ->
  anchor { 'zookeeper::end': }

}
