define zookeeper::znode
  $ensure = '',
  $assosiation = ''
) {
  
  if $ensure == 'present' {
    exec { "create znode ${name}":
      command => "echo \"create /${name} '${assosiation}'\" | ${zookeeper::install_dir}/bin/zkCli.sh",
      unless  => "if [[ `echo 'ls /' | /opt/zookeeper/bin/zkCli.sh | tail -n2 | head -n1` == *${name} ]]; then exit 0; else exit 1"
    }
  } else {
    exec { "delete znode ${name}":
      command => "echo \"rmr /${name}\" | ${zookeeper::install_dir}/bin/zkCli.sh",
      unless  => "if [[ `echo 'ls /' | /opt/zookeeper/bin/zkCli.sh | tail -n2 | head -n1` == *${name} ]]; then exit 1; else exit 0"
    }
  }
}
