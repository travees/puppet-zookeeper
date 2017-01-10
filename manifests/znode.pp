define zookeeper::znode (
  $ensure,
  $association = '',
) {

  validate_re($title, '^\/', "znode path must start with a '/'")
  if $title =~ /\/\.{1,2}(\/.*)?$/ {
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
      unless  => shellquote('znode_exists.sh', $title),
      path    => "/usr/share/zookeeper/bin:${zookeeper::archive_symlink_name}/bin:/bin:/usr/bin:/usr/local/bin",
      require => Class['::zookeeper::install'],
    }
  } elsif $ensure == 'absent' {
    exec { "delete znode ${name}":
      command => "${rm_cmd} | zkCli.sh",
      onlyif  => shellquote('znode_exists.sh', $title),
      path    => "/usr/share/zookeeper/bin:${zookeeper::archive_symlink_name}/bin:/bin:/usr/bin:/usr/local/bin",
      require => Class['::zookeeper::install'],
    }
  } else {
    fail("Parameter ensure failed on Zookeeper::Znode[${title}]: Invalid value '${ensure}'. Valid values are 'present' or 'absent'")
  }

}
