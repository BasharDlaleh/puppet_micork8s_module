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

  firewall { '000 Forward host 80 to master 80':
    chain     => 'PREROUTING',
    table     => 'nat',
    iniface   => "${facts['networking']['primary']}",
    proto     => 'tcp',
    dport     => '80',
    destination => "${facts['ipaddress']}/32",
    todest => "${master_ip}:80",
    jump      => 'DNAT',
  }

  firewall { '001 Forward host 443 to master 443':
    chain     => 'PREROUTING',
    table     => 'nat',
    iniface   => "${facts['networking']['primary']}",
    proto     => 'tcp',
    dport     => '443',
    destination => "${facts['ipaddress']}/32",
    todest => "${master_ip}:443",
    jump      => 'DNAT',
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
