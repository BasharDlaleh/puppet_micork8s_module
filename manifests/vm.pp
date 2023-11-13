class microk8s::vm (
    $vm_name      = '',
    $ipv4_address = '',
    $memory       = '8GB',
    $disk         = '60GiB',
    $passwd       = '$1$SaltSalt$YhgRYajLPrYevs14poKBQ0',
    $master       = false,
    $stage        = '',
){
  $addons = ['dns', 'rbac', 'ingress', 'metrics-server', 'hostpath-storage']

  file {'master_name':
    ensure  => file,
    command => "/tmp/master_name",
    content => $vm_name,
    onlyif  => $master,
  }

  file {"/tmp/${vm_name}.yaml":
    ensure  => file,
    content => epp('microk8s/lxd_profile.yml.epp',{
        ipv4_address => $ipv4_address,
        memory       => $memory,
        disk         => $disk,
        passwd       => $passwd,
    }),
  }

  exec {'launch':
    command => epp('microk8s/launch_script.sh.epp',{
        vm_name => $vm_name,
    }),
    require => File["/tmp/${vm_name}.yaml"],
  }

  exec {'microk8s-add-node':
    command => "lxc exec `cat /tmp/master_name` -- sudo microk8s add-node | grep 'microk8s join' | grep -v worker | head -1 > /tmp/microk8s-join 2>&1",
    unless  => $master,
    require => Exec['launch'],
  }

  exec {'microk8s-join-node':
    command => "lxc exec ${vm_name} -- sudo `cat /tmp/microk8s-join`",
    unless  => $master,
    require => [File['master_name'], Exec['launch', 'microk8s-add-node'] ],
  }

  $addons.each |$addon| {
    exec {"${addon}":
      command => "lxc exec `cat /tmp/master_name` -- sudo microk8s enable ${addon}",
      onlyif  => $master,
      require => [File['/tmp/addons.sh'], Exec['launch'] ],
    }
  }

  package {'nfs-coomon':
    ensure => latest,
    unless  => $master,
    require => Exec['apt update'],
  }
}
