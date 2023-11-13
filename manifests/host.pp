class microk8s::host (
  $master_ip         = '10.206.32.100',
  $local_nfs_storage = false,
){

  file {'/tmp/iptables.sh':
    ensure  => file,
        => '755',
    content => epp('microk8s/iptables.sh.epp',{
      mode  master_ip => $master_ip,
    }),
  }

  exec {'iptables':
    command => "/tmp/iptables.sh",
  }

  if $local_nfs_storage {
    include nfs
  }  
}
