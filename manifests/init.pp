# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include microk8s
class microk8s (
  $ipv4_address_cidr = '10.206.32.1/24',
){

  file {'/tmp/lxd_init.yaml':
    ensure  => file,
    content => epp('microk8s/lxd_init.yaml.epp',{
        ipv4_address_cidr => $ipv4_address_cidr,
    }),
  }

  exec {'init':
    command => 'lxd init --preseed < /tmp/lxd_init.yaml',
    require => File['/tmp/lxd_init.yaml'],
  }
}
