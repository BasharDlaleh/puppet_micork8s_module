# A description of what this class does
#
# @summary A class for creating LXD instances
#
# @example
#  class {'microk8s':
#    ipv4_address_cidr   => '10.206.32.0/24',
#    lxdbr0_ipv4_address => '10.206.32.1/24',
#    lxdbr0_ipv6_address => 'fd42:81d2:b869:f61c::1/64',
#    nodes => [{
#              'vm_name'      => 'master',
#              'ipv4_address' => '10.206.32.100',
#              'memory'       => '8GB',
#              'cpu'          => '2',
#              'disk'         => '60GiB',
#              'passwd'       => '$1$SaltSalt$YhgRYajLPrYevs14poKBQ0',
#              'master'       => true
#             },
#             {
#              'vm_name'      => 'worker1',
#              'ipv4_address' => '10.206.32.101',
#              'memory'       => '8GB',
#              'cpu'          => '2',
#              'disk'         => '60GiB',
#              'passwd'       => '$1$SaltSalt$YhgRYajLPrYevs14poKBQ0',
#              }],
#     local_nfs_storage => true,
#     master_ip         => '10.206.32.100',
#     master_name       => 'master',
#     nfs_shared_folder => '/mnt/k8s_nfs_share',
#     enable_host_ufw   => true,
#     kubectl_user      => 'ubuntu',
#     kubectl_user_home => '/home/ubuntu',
#  }
class microk8s (
  $ipv4_address_cidr = '10.206.32.0/24',
  $lxdbr0_ipv4_address = '10.206.32.1/24',
  $lxdbr0_ipv6_address  = 'fd42:81d2:b869:f61c::1/64',
  $nodes = [{
              'vm_name'      => 'master',
              'ipv4_address' => '10.206.32.100',
              'ipv6_address' => 'fd42:81d2:b869:f61c:216:3eff:fe4e:a800',
              'memory'       => '8GB',
              'cpu'          => '2',
              'disk'         => '60GiB',
              'passwd'       => '$1$SaltSalt$YhgRYajLPrYevs14poKBQ0',
              'master'       => true
             },
             {
              'vm_name'      => 'worker1',
              'ipv4_address' => '10.206.32.101',
              'ipv6_address' => 'fd42:81d2:b869:f61c:216:3eff:fea4:6d85',
              'memory'       => '8GB',
              'cpu'          => '2',
              'disk'         => '60GiB',
              'passwd'       => '$1$SaltSalt$YhgRYajLPrYevs14poKBQ0',
              },
              {
              'vm_name'      => 'worker2',
              'ipv4_address' => '10.206.32.102',
              'ipv6_address' => 'fd42:81d2:b869:f61c:216:3eff:fe54:c89a',
              'memory'       => '8GB',
              'cpu'          => '2',
              'disk'         => '60GiB',
              'passwd'       => '$1$SaltSalt$YhgRYajLPrYevs14poKBQ0',
              }],
  $local_nfs_storage = true,
  $master_ip         = '10.206.32.100',
  $master_name       = 'master',
  $nfs_shared_folder = '/mnt/k8s_nfs_share',
  $enable_host_ufw   = true,
  $kubectl_user      = 'ubuntu',
  $kubectl_user_home = '/home/ubuntu',
){

  stage { 'host': }
  Stage['main'] -> Stage['host']

  file {'/tmp/lxd_init.yaml':
    ensure  => file,
    content => epp('microk8s/lxd_init.yaml.epp',{
        lxdbr0_ipv4_address => $lxdbr0_ipv4_address,
        lxdbr0_ipv6_address => $lxdbr0_ipv6_address,
    }),
  }

  exec {'init':
    command => '/snap/bin/lxd init --preseed < /tmp/lxd_init.yaml',
    require => File['/tmp/lxd_init.yaml'],
  }

  class {'microk8s::instances':
    nodes             => $nodes,
    master_name       => $master_name,
  }

  class {'microk8s::host':
    master_ip         => $master_ip,
    master_name       => $master_name,
    local_nfs_storage => $local_nfs_storage,
    nfs_shared_folder => $nfs_shared_folder,
    enable_host_ufw   => $enable_host_ufw,
    kubectl_user      => $kubectl_user,
    kubectl_user_home => $kubectl_user_home,
    stage             => 'host',
  }
}
