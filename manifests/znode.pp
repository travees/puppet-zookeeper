define zookeeper::znode(
  $ensure = '',
  $association = ''
) {

  validate_re($name, '^\/', "znode path must start with a '/'")
  if $name =~ /\/\.{1,2}(\/.*)?$/ {
    fail("znode name cannot be '.' or '..'")
  }

  $create_cmd = shellquote(
    '/bin/echo',
    "create ${name}",
    "\'${association}\'"
  )

  $rm_cmd = shellquote(
    '/bin/echo',
    "rmr ${name}"
  )

  if $ensure == 'present' {
    exec { "create znode ${name}":
      command => "${create_cmd} | zkCli.sh",
      unless  => shellquote('znode_exists.sh', $name),
      path    => "/usr/share/zookeeper/bin:${zookeeper::install_dir}/bin:/bin:/usr/bin:/usr/local/bin",
      require => Class['::zookeeper::install'],
                
    }
  } else {
    exec { "delete znode ${name}":
      command => "${rm_cmd} | zkCli.sh",
      onlyif  => shellquote('znode_exists.sh', $name),
      path    => "/usr/share/zookeeper/bin:${zookeeper::install_dir}/bin:/bin:/usr/bin:/usr/local/bin",
      require => Class['::zookeeper::install'],
    }
  }

}
