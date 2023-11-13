define microk8s::vm (
    $vm_name      = '',
    $ipv4_address = '',
    $memory       = '8GB',
    $disk         = '60GiB',
    $passwd       = '$1$SaltSalt$YhgRYajLPrYevs14poKBQ0',
    $master       = false,
    $master_name  = 'master',
){
  $addons = ['dns', 'rbac', 'ingress', 'metrics-server', 'hostpath-storage']

  file {"/tmp/${vm_name}.yaml":
    ensure  => file,
    content => epp('microk8s/lxd_profile.yaml.epp',{
        ipv4_address => $ipv4_address,
        memory       => $memory,
        disk         => $disk,
        passwd       => $passwd,
    }),
  }

  exec {"launch_${vm_name}":
    command => epp('microk8s/launch_script.sh.epp',{
        vm_name => $vm_name,
    }),
    require => File["/tmp/${vm_name}.yaml"],
  }

  exec {"microk8s-add-node_${vm_name}":
    command => "sudo /snap/bin/lxc exec `cat /tmp/${master_name}` -- sudo microk8s add-node | grep 'microk8s join' | grep -v worker | head -1 > /tmp/microk8s-join 2>&1",
    unless  => $master,
    require => Exec["launch_${vm_name}"],
  }

  exec {"microk8s-join-node_${vm_name}":
    command => "sudo /snap/bin/lxc exec ${vm_name} -- sudo `cat /tmp/microk8s-join`",
    unless  => $master,
    require => Exec["microk8s-add-node_${vm_name}"],
  }

  $addons.each |$addon| {
    exec {"${vm_name}_${addon}":
      command => "sudo /snap/bin/lxc exec `cat /tmp/${master_name}` -- sudo microk8s enable ${addon}",
      onlyif  => $master,
      require => Exec["launch_${vm_name}", "microk8s-join-node_${vm_name}"],
    }
  }

  exec {"apt-update_${vm_name}":
    command => "sudo /snap/bin/lxc exec ${vm_name} -- sudo apt update",
  }

  exec {"nfs-common_${vm_name}":
    command => "sudo /snap/bin/lxc exec ${vm_name} -- sudo apt install nfs-common -y",
    require => Exec["apt-update_${vm_name}"],
  }
}
