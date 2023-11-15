class microk8s::nfs (
  $nfs_shared_folder = '',
){
  exec {"apt_update_host":
    command => "apt update",
  }

  package { 'nfs-kernel-server':
    ensure  => latest,
    require  => Exec['apt_update_host'],
  }

  package { 'nfs-common':
    ensure  => latest,
    require  => Exec['apt_update_host'],
  }

  file {"${}":
    ensure  => directory,
    mode    => 777,
    owner   => 'nobody',
    group   => 'nogroup',
  }

  exec {'exports':
    command => "grep '${nfs_shared_folder}  ${microk8s::ipv4_address_cidr}(rw,sync,no_root_squash,no_subtree_check)' /etc/exports || echo '${nfs_shared_folder}  ${microk8s::ipv4_address_cidr}(rw,sync,no_root_squash,no_subtree_check)' >> /etc/exports",
  }

  service {'nfs-kernel-server':
    ensure => running,
    enable  => true,
    require => Package['nfs-kernel-server'],
  }

  iptables::listen::all {'nfs':
    trusted_nets => ["${microk8s::ipv4_address_cidr}"],
    dports      => [ 2049 ],
  }
}

