class microk8s::nfs (
  $nfs_shared_folder = '',
){
  exec {"apt_update_host":
    command => "/usr/bin/apt update",
  }

  package { 'nfs-kernel-server':
    ensure  => latest,
    require  => Exec['apt_update_host'],
  }

  package { 'nfs-common':
    ensure  => latest,
    require  => Exec['apt_update_host'],
  }

  file {"${nfs_shared_folder}":
    ensure  => directory,
    mode    => '777',
    owner   => 'nobody',
    group   => 'nogroup',
  }

  exec {'exports':
    command => "/usr/bin/grep '${nfs_shared_folder}  ${microk8s::ipv4_address_cidr}(rw,sync,no_root_squash,no_subtree_check)' /etc/exports || /usr/bin/echo '${nfs_shared_folder}  ${microk8s::ipv4_address_cidr}(rw,sync,no_root_squash,no_subtree_check)' >> /etc/exports",
  }

  service {'nfs-kernel-server':
    ensure => running,
    enable  => true,
    require => Package['nfs-kernel-server'],
  }

  firewall { 'allow nfs tcp access':
    dport  => [2049],
    proto  => 'tcp',
    source => "${microk8s::ipv4_address_cidr}",
    action => 'accept',
  }

  firewall { 'allow nfs udp access':
    dport  => [2049],
    proto  => 'udp',
    source => "${microk8s::ipv4_address_cidr}",
    action => 'accept',
  }
}

