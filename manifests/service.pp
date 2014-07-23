# Class: zookeeper::service

class zookeeper::service(
  $cfg_dir = '/etc/zookeeper/conf',
){
  require zookeeper::install

  file { '/etc/init/zookeeper':
    ensure  => present,
    content => template('zookeeper/init.zookeeper.erb')
  }

  file { '/etc/init.d/zookeeper':
    ensure  => present,
    content => template('zookeeper/initd.zookeeper.erb')
  }

  service { 'zookeeper':
    ensure     => 'running',
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => [
      Package['zookeeperd'],
      File["${cfg_dir}/zoo.cfg"],
      File['/etc/init/zookeeper'],
      File['/etc/init.d/zookeeper']
    ]
  }
}
