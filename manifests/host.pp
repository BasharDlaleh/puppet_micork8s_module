class microk8s::host (
  $master_ip         = '10.206.32.100',
  $local_nfs_storage = false,
  $nfs_shared_folder = '',
){

  file {'/tmp/iptables.sh':
    ensure  => file,
    mode    => '755',
    content => epp('microk8s/iptables.sh.epp',{
      master_ip => $master_ip,
    }),
  }

  exec {'iptables':
    command => "/tmp/iptables.sh",
  }

  if $local_nfs_storage {
    class {'microk8s::nfs':
      nfs_shared_folder => $nfs_shared_folder,
    }
  }  
}
