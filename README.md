# microk8s

Welcome to your new module. A short overview of the generated parts can be found
in the [PDK documentation][1].

The README template below provides a starting point with details about what
information to include in your README.

## Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with microk8s](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with microk8s](#beginning-with-microk8s)
3. [Usage - Configuration and customization options](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

Microk8s module deploys a production-ready multi-node Microk8s cluster on LXD VMs on a dedicated server, this approach is helpful for those who want to deploy a small and affordable Kubernetes cluster to take advantage of the automation and observability it provides but not for those looking for high availability as this is still a one node cluster physically.

## Setup

### Setup Requirements

* This module was tested on Ubuntu 20.04 dedicated server.
* at least 32GB of RAM and 4 CPU cores.
* public ipv4 address for your server.

### Beginning with microk8s

in the following sections you will see how to define your cluster nodes specifications and provision the cluster with minimal effort.

## Usage

you can use this module either with the default values or by defining you own values:

#### Defaults

this module already has default values defined for everything as below, you can go with these if you don't wish to make any changes,

    ipv4 address range:        10.206.32.1/24
    number of nodes:           one master and 2 workers
    memory per node:           8 GB
    cpu per node:              2
    disk per node:             60 GB
    local NFS storage on host: enabled
    master ipv4:               10.206.32.100
    NFS shared folder:         /mnt/k8s_nfs_share

so you just have to include the module in your puppet manifest:

`include microk8s`

**Note:** by default we are defining a local NFS storage on the host on the path /mnt/k8s_nfs_share which is better than using Kubernetes hostpath storage but you can disable that as you will see in the section below.

#### Customization

If you wish to customize the defaults you can pass them to the main class microk8s,

```puppet
class {'microk8s': 
  ipv4_address_cidr => '10.206.32.1/24',
  nodes = [{
              'vm_name'      => 'master',
              'ipv4_address' => '10.206.32.100',
              'memory'       => '8GB',
              'cpu'          => '2',
              'disk'         => '60GiB',
              'passwd'       => '$1$SaltSalt$YhgRYajLPrYevs14poKBQ0',
              'master'       => true
             },
             {
              'vm_name'      => 'worker1',
              'ipv4_address' => '10.206.32.101',
              'memory'       => '8GB',
              'cpu'          => '2',
              'disk'         => '60GiB',
              'passwd'       => '$1$SaltSalt$YhgRYajLPrYevs14poKBQ0',
              },
              {
              'vm_name'      => 'worker2',
              'ipv4_address' => '10.206.32.102',
              'memory'       => '8GB',
              'cpu'          => '2',
              'disk'         => '60GiB',
              'passwd'       => '$1$SaltSalt$YhgRYajLPrYevs14poKBQ0',
              }],
  local_nfs_storage => true,
  master_ip         => '10.206.32.100',
  master_name       => 'master',
  nfs_shared_folder => '/mnt/k8s_nfs_share',
}
```

**Note:** note that the nodes specifications are passed as an array of hashes so if you wish to change even one value you'll have to pass all the other values inside the nodes array with it.

**Note:** the 'passwd' parameter is the hashed password for the ubuntu user created inside the LXD VM which you'll prbably won't need as you can exec into the VM from the host without it.

## Limitations

For a list of supported operating systems, see metadata.json.

## Development

If you wish to contribute to this project you can submit a pull request to the repo

##### some ideas for contribution

1. currently the used LXD profiles only work for VMs, you can try to make it work for containers which is better for local development use.
2. add parameters for enabling the most popular K8S addons like Prometheus, ELK,....etc
