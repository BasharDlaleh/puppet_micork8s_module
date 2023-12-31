define microk8s::vm (
    $vm_name      = '',
    $ipv4_address = '',
    $ipv6_address = '',
    $memory       = '8GB',
    $cpu          = '2',
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
        ipv6_address => $ipv6_address,
        memory       => $memory,
        cpu          => $cpu,
        disk         => $disk,
        passwd       => $passwd,
        vm_name      => $vm_name,
    }),
  }

  exec {"create_profile_${vm_name}":
    command => "/snap/bin/lxc profile create ${vm_name} || true && cat /tmp/${vm_name}.yaml | /snap/bin/lxc profile edit ${vm_name}",
    require => File["/tmp/${vm_name}.yaml"],
  }

  file {"/tmp/wait_${vm_name}.sh":
    ensure  => file,
    mode    => '755',
    content => epp('microk8s/wait_script.sh.epp',{
        vm_name      => $vm_name,
        ipv4_address => $ipv4_address
    }),
  }

  exec {"launch_${vm_name}":
    command => "/snap/bin/lxc launch ubuntu:20.04 ${vm_name} --profile ${vm_name} --vm || true",
    require => [File["/tmp/wait_${vm_name}.sh"], Exec["create_profile_${vm_name}"]],
  }

  exec {"wait_${vm_name}":
    command => "/tmp/wait_${vm_name}.sh",
    require => Exec["launch_${vm_name}"],
  }

  if $master == false {
    exec {"microk8s-add-node_${vm_name}":
      command => "/snap/bin/lxc exec ${master_name} -- sudo microk8s add-node | grep 'microk8s join' | grep -v worker | head -1 > /tmp/microk8s-join-${vm_name} 2>&1",
      require => Exec["wait_${vm_name}"],
    }

    exec {"microk8s-join-node_${vm_name}":
      command => "/snap/bin/lxc exec ${vm_name} -- sudo `cat /tmp/microk8s-join-${vm_name}` || true",
      require => Exec["microk8s-add-node_${vm_name}"],
    }
  }

  
  if $master == true {
    $addons.each |$addon| {
      exec {"enable_addon_${addon}":
        command => "/snap/bin/lxc exec ${master_name} -- sudo microk8s enable ${addon}",
        require => Exec["wait_${vm_name}"],
      }
    }
  }

  exec {"apt-update_${vm_name}":
    command => "/snap/bin/lxc exec ${vm_name} -- sudo apt-get update",
    require => Exec["wait_${vm_name}"],
  }

  exec {"nfs-common_${vm_name}":
    command => "/snap/bin/lxc exec ${vm_name} -- sudo apt-get install -y nfs-common",
    require => Exec["apt-update_${vm_name}"],
  }
}
