class microk8s::nfs (
  $nfs_shared_folder = '',
){
  Apt::Source <| |> -> Package <| |>

  #package { 'nfs-kernel-server':
  #  ensure  => latest,
  #}

  #package { 'nfs-common':
  #  ensure  => latest,
  #}

  #file {"${nfs_shared_folder}":
  #  ensure  => directory,
  #  mode    => '777',
  #  owner   => 'nobody',
  #  group   => 'nogroup',
  #}

  #exec {'export_nfs':
  #  command => "/usr/bin/grep '${nfs_shared_folder}  ${microk8s::ipv4_address_cidr}(rw,sync,no_root_squash,no_subtree_check)' /etc/exports || /usr/bin/echo '${nfs_shared_folder}  ${microk8s::ipv4_address_cidr}(rw,sync,no_root_squash,no_subtree_check)' >> /etc/exports",
  #  require => Package['nfs-kernel-server'],
  #}

  #service {'nfs-kernel-server':
  #  ensure => running,
  #  enable  => true,
  #  require => Package['nfs-kernel-server'],
  #}

  if $enable_host_ufw == false {
    firewall { '000 allow nfs tcp access':
      dport  => 2049,
      proto  => 'tcp',
      source => "${microk8s::ipv4_address_cidr}",
      action => 'accept',
    }

    firewall { '001 allow nfs udp access':
      dport  => 2049,
      proto  => 'udp',
      source => "${microk8s::ipv4_address_cidr}",
      action => 'accept',
    }
  }
  else {
    class { 'ufw': }
    
    ufw::allow { 'allow-nfs-from-trusted':
      port => '2049'
      from => "${microk8s::ipv4_address_cidr}",
    }
  }
}

