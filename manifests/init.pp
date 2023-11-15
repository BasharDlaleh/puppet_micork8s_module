# A description of what this class does
#
# @summary A class for creating LXD instances
#
# @example
#  class {'microk8s':
#    nodes => [{
#              vm_name      => 'master',
#              ipv4_address => '10.206.32.100',
#              memory       => '8GB',
#              disk         => '60GiB',
#              passwd       => '$1$SaltSalt$YhgRYajLPrYevs14poKBQ0',
#              master       => true
#             },
#             {
#              vm_name      => 'worker1',
#              ipv4_address => '10.206.32.101',
#              memory       => '8GB',
#              disk         => '60GiB',
#              passwd       => '$1$SaltSalt$YhgRYajLPrYevs14poKBQ0',
#              }],
#    local_nfs_storage = true,
#  }
class microk8s (
  $ipv4_address_cidr = '10.206.32.1/24',
  $nodes = [{
              'vm_name'      => 'master',
              'ipv4_address' => '10.206.32.100',
              'memory'       => '2GB',
              'disk'         => '10GiB',
              'passwd'       => '$1$SaltSalt$YhgRYajLPrYevs14poKBQ0',
              'master'       => true
             },
             {
              'vm_name'      => 'worker1',
              'ipv4_address' => '10.206.32.101',
              'memory'       => '2GB',
              'disk'         => '10GiB',
              'passwd'       => '$1$SaltSalt$YhgRYajLPrYevs14poKBQ0',
              }],
  $local_nfs_storage = true,
  $master_ip         = '10.206.32.100',
  $master_name       = 'master',
  $nfs_shared_folder = '/mnt/k8s_nfs_share',
){

  stage { 'host': }
  Stage['main'] -> Stage['host']

  file {'/tmp/lxd_init.yaml':
    ensure  => file,
    content => epp('microk8s/lxd_init.yaml.epp',{
        ipv4_address_cidr => $ipv4_address_cidr,
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
    local_nfs_storage => $local_nfs_storage,
    nfs_shared_folder => $nfs_shared_folder,
    stage             => 'host',
  }
}
