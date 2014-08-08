# Class: zookeeper::config
#
# This module manages the zookeeper configuration directories
#
# Parameters:
# [* id *]  zookeeper instance id: between 1 and 255
#
# [* servers *] an Array - specify all zookeeper servers
# The fist port is used by followers to connect to the leader
# The second one is used for leader election
#     server.1=zookeeper1:2888:3888
#     server.2=zookeeper2:2888:3888
#     server.3=zookeeper3:2888:3888
#
#
# Actions: None
#
# Requires: zookeeper::install, zookeeper
#
# Sample Usage: include zookeeper::config
#
class zookeeper::config(
  $id                      = $zookeeper::id,
  $datastore               = $zookeeper::datastore,
  $client_ip               = $zookeeper::client_ip,
  $client_port             = $zookeeper::client_port,
  $election_port           = $zookeeper::election_port,
  $leader_port             = $zookeeper::leader_port,
  $snap_count              = $zookeeper::snap_count,
  $log_dir                 = $zookeeper::log_dir,
  $cfg_dir                 = $zookeeper::cfg_dir,
  $user                    = $zookeeper::user,
  $group                   = $zookeeper::group,
  $java_bin                = $zookeeper::java_bin,
  $java_opts               = $zookeeper::java_opts,
  $pid_dir                 = $zookeeper::pid_dir,
  $pid_file                = $zookeeper::pid_file,
  $zoo_main                = $zookeeper::zoo_main,
  $log4j_prop              = $zookeeper::log4j_prop,
  $servers                 = $zookeeper::servers,
  $snap_retain_count       = $zookeeper::snap_retain_count,
  $purge_interval          = $zookeeper::purge_interval,
  $rollingfile_threshold   = $zookeeper::rollingfile_threshold,
  $tracefile_threshold     = $zookeeper::tracefile_threshold,
  $max_allowed_connections = $zookeeper::max_allowed_connections,
  $export_tag              = $zookeeper::export_tag,
  $peer_type               = $zookeeper::peer_type,
  $exhibitor_managed       = $zookeeper::exhibitor_managed
) {

  file { $cfg_dir:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    recurse => true,
    mode    => '0644',
  }

  file { $log_dir:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    recurse => true,
    mode    => '0644',
  }

  file { $datastore:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    recurse => true,
  }

  file { "${datastore}/myid":
    ensure  => file,
    content => template('zookeeper/conf/myid.erb'),
    owner   => $user,
    group   => $group,
    mode    => '0644',
    require => File[$datastore],
    notify  => Class['zookeeper::service'],
  }
  
  if $exhibitor_manaaged == 'false' {
    file { "${cfg_dir}/zoo.cfg":
      owner   => $user,
      group   => $group,
      mode    => '0644',
      content => template('zookeeper/conf/zoo.cfg.erb'),
      notify  => Class['zookeeper::service'],
    }
  }

  file { "${cfg_dir}/environment":
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template('zookeeper/conf/environment.erb'),
    notify  => Class['zookeeper::service'],
  }

  file { "${cfg_dir}/log4j.properties":
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template('zookeeper/conf/log4j.properties.erb'),
    notify  => Class['zookeeper::service'],
  }

  # keep track of all hosts in a cluster
  zookeeper::host { $client_ip:
    id            => $id,
    client_ip     => $client_ip,
    election_port => $election_port,
    leader_port   => $leader_port,
  }
}
