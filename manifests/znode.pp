define zookeeper::znode(
  $ensure = '',
  $assosiation = ''
) {

  $znode_check = "/bin/bash -c \"if [[ \\\"\$(echo 'stat /${name}' | /opt/zookeeper/bin/zkCli.sh 2>&1 1>/dev/null)\\\" == 'Node does not exist'* ]]; then exit 1; else exit 0; fi\""

  if $ensure == 'present' {
    exec { "create znode ${name}":
      command => "/bin/echo \"create /${name} '${assosiation}'\" | ${zookeeper::install_dir}/bin/zkCli.sh",
      unless  => $znode_check,
    }
  } else {
    exec { "delete znode ${name}":
      command => "/bin/echo \"rmr /${name}\" | ${zookeeper::install_dir}/bin/zkCli.sh",
      onlyif  => $znode_check,
    }
  }
}
