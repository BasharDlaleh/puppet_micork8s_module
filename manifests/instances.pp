# microk8s::instance
#
# A description of what this class does
#
# @summary A class for creating LXD instances
#
# @example
#  class {'microk8s::instance':
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

class microk8s::instances (
  $nodes = [],
  $local_nfs_storage = false,
){
  stage { 'host': }
  Stage['main'] -> Stage['host']

  $nodes.each |$node| {
    if $node[master] == true {
      $microk8s::master_ip   = $node[ipv4_address]
      $microk8s::master_name = $node[vm_name]
    }
  }

  $nodes.each |$node| {
    if $node[master] == true {
      microk8s::vm {"${node[vm_name]}":
          vm_name      => $node[vm_name],
          ipv4_address => $node[ipv4_address],
          memory       => $node[memory],
          disk         => $node[disk],
          passwd       => $node[passwd],
          master       => $node[master],
          require      => Microk8s::Vm["${microk8s::master_name}"]
      }
    }
    else {
      microk8s::vm {"${node[vm_name]}":
          vm_name      => $node[vm_name],
          ipv4_address => $node[ipv4_address],
          memory       => $node[memory],
          disk         => $node[disk],
          passwd       => $node[passwd],
          master       => $node[master],
      }
    }
  }

  class {'microk8s::host':
    master_ip         => $microk8s::master_ip,
    local_nfs_storage => $local_nfs_storage,
    stage             => 'host',
  }
}
