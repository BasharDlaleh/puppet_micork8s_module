# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include microk8s
class microk8s {
  exec {'init':
    command => "lxd init --preseed < ${epp('microk8s/init.yml.epp',{
        ipv4_address => $ipv4_address,
      })}"
  }

  file {'/tmp/master_profile.yaml':
    ensure  => file,
    content => 
  }
}
