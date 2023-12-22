class microk8s::instances (
  $nodes = [],
  $master_name       = 'master',
){
  $nodes.each |$node| {
    if $node['master'] == true {
      microk8s::vm {"${node['vm_name']}":
          vm_name      => $node['vm_name'],
          ipv4_address => $node['ipv4_address'],
          ipv6_address => $node['ipv6_address'],
          memory       => $node['memory'],
          cpu          => $node['cpu'],
          disk         => $node['disk'],
          passwd       => $node['passwd'],
          master       => $node['master'],
          master_name  => $master_name,
      }
    }
    else {
      microk8s::vm {"${node[vm_name]}":
          vm_name      => $node['vm_name'],
          ipv4_address => $node['ipv4_address'],
          ipv6_address => $node['ipv6_address'],
          memory       => $node['memory'],
          cpu          => $node['cpu'],
          disk         => $node['disk'],
          passwd       => $node['passwd'],
          master       => $node['master'],
          master_name  => $master_name,
          require      => Microk8s::Vm["${master_name}"],
      }
    }
  }
}
