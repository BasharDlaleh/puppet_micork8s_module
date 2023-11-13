CPUS="2"
MEMORY="8192"

Vagrant.configure("2") do |config|

  config.vm.box = "bento/ubuntu-20.04"
  config.vm.hostname = "microk8s.puppet.vm"
  config.vm.network "private_network", ip: "192.168.33.15"

  config.vm.provider "virtualbox" do |v|
    v.name = "microk8s.puppet.vm"
    v.memory = MEMORY
    v.cpus = CPUS
  end

end
