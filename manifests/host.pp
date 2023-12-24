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
  
  if $enable_host_ufw {
    class {'ufw':
      manage_package           => true,
      package_name             => 'ufw',
      manage_service           => true,
      service_name             => 'ufw',
      service_ensure           => 'running',
      rules                    => {
        'allow ssh' => {
        'ensure'         => 'present',
        'action'         => 'allow',
        'to_ports_app'   => 22,
        'proto'          => 'tcp'
        },
        'allow http' => {
        'ensure'         => 'present',
        'action'         => 'allow',
        'to_ports_app'   => 80,
        'proto'          => 'tcp'
        },
        'allow https' => {
        'ensure'         => 'present',
        'action'         => 'allow',
        'to_ports_app'   => 443,
        'proto'          => 'tcp'
        },
        'allow in on lxdbr0' => {
        'ensure'         => 'present',
        'action'         => 'allow',
        'direction'      => 'in',
        'interface_in'      => 'lxdbr0',

        },
      },
      routes                   => {
        'route allow in on lxdbr0' => {
        'ensure'         => 'present',
        'action'         => 'allow',
        'interface_in'   => 'lxdbr0',
        },
        'route allow out on lxdbr0' => {
        'ensure'         => 'present',
        'action'         => 'allow',
        'interface_out'  => 'lxdbr0',
        },
      },
      purge_unmanaged_rules    => true,
      purge_unmanaged_routes   => true,
    }
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
