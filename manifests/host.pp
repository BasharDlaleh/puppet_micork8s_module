class microk8s::host (
  $master_ip         = '10.206.32.100',
  $master_name       = 'master',
  $local_nfs_storage = false,
  $nfs_shared_folder = '',
  $enable_host_ufw   = false,
  $kubectl_user      = 'ubuntu',
  $kubectl_user_home = '/home/ubuntu',
){
  # add routing rules to route web traffic from host to LXD master
  #file {'/tmp/persist-iptables.sh':
  #  ensure  => file,
  #  mode    => '755',
  #  content => epp('microk8s/persist-iptables.sh.epp',{
  #    master_ip => $master_ip,
  #  }),
  #}

  #firewall { '000 Forward host 80 to master 80':
  #  chain     => 'PREROUTING',
  #  table     => 'nat',
  #  iniface   => "${facts['networking']['primary']}",
  #  proto     => 'tcp',
  #  dport     => '80',
  #  destination => "${facts['ipaddress']}/32",
  #  todest => "${master_ip}:80",
  #  jump      => 'DNAT',
  #}

  #firewall { '001 Forward host 443 to master 443':
  #  chain     => 'PREROUTING',
  #  table     => 'nat',
  #  iniface   => "${facts['networking']['primary']}",
  #  proto     => 'tcp',
  #  dport     => '443',
  #  destination => "${facts['ipaddress']}/32",
  #  todest => "${master_ip}:443",
  #  jump      => 'DNAT',
  #}

  #exec {'persist-iptables':
  #  command => "/tmp/persist-iptables.sh",
  #  require => File['/tmp/persist-iptables.sh']
  #}

  # allow http, https, ssh in ufw
  class { 'ufw': }
  
  if $enable_host_ufw {
    ufw::allow {'allow-ssh':
      port => '22'
    }

    ufw::allow {'allow-http':
      port => '80'
    }

    ufw::allow {'allow-https':
      port => '443'
    }

    ufw::allow {'allow-lxdbr0':
      port      => 'Anywhere',
      interface => 'lxdbr0',
    }

    #ufw::route {'route-allow-in-lxdbr0':
    #  interface => 'lxdbr0',
    #}

    #ufw::allow {'route-allow-out-lxdbr0':
    #  interface => 'lxdbr0',
    #}
  } 

  # configure nfs storage
  #if $local_nfs_storage {
  #  class {'microk8s::nfs':
  #    nfs_shared_folder => $nfs_shared_folder,
  #    enable_host_ufw   => $enable_host_ufw,
  #  }
  #}

  # install and configure kubectl on host
  #include kubectl

  #file {"${kubectl_user_home}/.kube":
  #  ensure  => directory,
  #  mode    => '775',
  #  owner   => "${kubectl_user}",
  #  group   => "${kubectl_user}",
  #}

  #exec {"configure-kubectl":
  #    command => "/snap/bin/lxc exec ${master_name} -- sudo microk8s config > ${kubectl_user_home}/.kube/config 2>&1",
  #    require => File["${kubectl_user_home}/.kube"],
  #}  
}
