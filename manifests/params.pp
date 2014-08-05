class zookeeper::params {
  
  $id          = '1',
  $datastore   = '/var/lib/zookeeper',
  # fact from which we get public ip address
  $client_ip   = $::ipaddress,
  $client_port = 2181,
  $log_dir     = '/var/log/zookeeper',
  $cfg_dir     = '/etc/zookeeper/conf',
  $user        = 'zookeeper',
  $group       = 'zookeeper',
  $java_bin    = '/usr/bin/java',
  $java_opts   = '',
  $pid_dir     = '/var/run/zookeeper',
  $pid_file    = '$PIDDIR/zookeeper.pid',
  $zoo_main    = 'org.apache.zookeeper.server.quorum.QuorumPeerMain',
  $lo4j_prop   = 'INFO,ROLLINGFILE',
  $cleanup_sh  = '/usr/share/zookeeper/bin/zkCleanup.sh',
  $servers     = [''],
  $ensure      = present,
  $snap_count  = 10000,
  # since zookeeper 3.4, for earlier version cron task might be used
  $snap_retain_count       = 3,
  # interval in hours, purging enabled when >= 1
  $purge_interval          = 0,
  # log4j properties
  $rollingfile_threshold   = 'ERROR',
  $tracefile_threshold     = 'TRACE',
  $max_allowed_connections = 10,
  $peer_type               = 'UNSET',
  $install_method    = 'deb',
  $package_mirror    = 'http://www.mirrorservice.org/sites/ftp.apache.org/zookeeper',
  $install_dir       = '/opt/zookeeper'
  
}
