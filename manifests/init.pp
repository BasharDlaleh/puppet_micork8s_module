# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include microk8s
class microk8s (
  $ipv4_address_cidr = '10.206.32.1/24',
  $nodes = [{
              vm_name      => 'master',
              ipv4_address => '10.206.32.100',
              memory       => '2GB',
              disk         => '10GiB',
              passwd       => '$1$SaltSalt$YhgRYajLPrYevs14poKBQ0',
              master       => true
             },
             {
              vm_name      => 'worker1',
              ipv4_address => '10.206.32.101',
              memory       => '2GB',
              disk         => '10GiB',
              passwd       => '$1$SaltSalt$YhgRYajLPrYevs14poKBQ0',
              }],
  $local_nfs_storage = false,
){

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
    local_nfs_storage => false,
  }
}
