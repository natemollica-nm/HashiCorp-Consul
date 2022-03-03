# Vagrant Consul Cluster

A 3-node [Consul][a01] cluster with 2-node compute client resources to run services on to demonstrate how Consul works, and to learn about how it operates.

## Prerequisites

1. [macOS][a15] Macbook with macOS Monterey v12.1 or newer.
1. [Vagrant][a13] 1.9.1 or newer.
1. [VirtualBox][a14] 5.1.x.  Older versions may work, but I have not tested it.

## Cluster Architecture

The `Vagrantfile` is set up to create 6 hosts of various types as described below.

|   Hostname   | Description |
|----------|-------------|
| `bootstrap` | This is the first Consul server that is started in bootstrap mode to expect 2 more Consul servers to join the server cluster.  Its sole purpose is to bootstrap the Consul cluster, after which it can be destroyed.The Consul start-up command is hard-coded to [bootstrap][a08] the Consul cluster, while the rest of the 3-node Consul servers are told to [join][a09] an agent in an existing Consul cluster.  Since the bootstrap server is hard-coded to bootstrap, it has outlived its function after the bootstrap process unless its hard-coded command is updated.  However, since I try to build only [immutable infrastructure][a10], updating the command on the bootstrap host would be less than ideal, so I just destroy it instead since the rest of the servers are already bootstrapped, and can come and go without the operations of the cluster getting impacted as long as we maintain a quorum online. |
| `consul-0[1-3]` | This is a 3-node Consul server cluster that is bootstrapped by the bootstrap host, and has quorum as a Consul cluster even after the `bootstrap` host is destroyed. |
| `compute-0[1-2]` | A 2-node compute cluster, each running a Consul client, Docker and [Registrator][a06] to update the location of services running on them. |


## Usage

### Cluster Creation

```
# vConsul.sh Bash Script to perform Vagrant Provisioning, Startup, and Shutdown functions of Consul Cluster
# Initially build or rebuild Consul Cluster
 ./vConsul.sh -init

# Reload/Startup Consul Cluster Members
 ./vConsul.sh -start

# Shutdown Consul Cluster Members
 ./vConsul.sh -stop
 
# Re-provision Consul Cluster Members
 ./vConsul.sh -reprovision

# Create the first Consul server to bootstrap the Consul cluster
vagrant up bootstrap

# Create the rest of the Consul servers
vagrant up consul-01
vagrant up consul-02
vagrant up consul-03

# Create compute VMs
vagrant up client-01
vagrant up client-02

# Destroy the BootStrap VM since no longer needed
vagrant destroy bootstrap -f

# Develop/Learn HashiCorp's Consul Service Mesh Control Plane Solution
```
## References

1. [Consul documentation][a01]
1. [Wicked Awesome Tech: Setting up Consul Service Discovery for Mesos in 10 Minutes][a02]
1. [Get Docker for Ubuntu][a03]
1. [kelseyhightower/setup-network-environment][a04]
1. [AWS Compute Blog: Service Discovery via Consul with Amazon ECS][a05]
1. [gliderlabs/registrator][a06]
1. [Sreenivas Makam's Blog: Service Discovery with Consul][a07]
1. [Setting up a Consul cluster for testing and development with Vagrant (Part 2)][a16]
1. [AWS Quick Starts: HashiCorp Consul on AWS][a15]

[a01]: https://www.consul.io/
[a02]: http://www.wickedawesometech.us/2016/04/setting-up-consul-service-discovery-in.html
[a03]: https://docs.docker.com/engine/installation/linux/ubuntu/
[a04]: https://github.com/kelseyhightower/setup-network-environment
[a05]: https://aws.amazon.com/blogs/compute/service-discovery-via-consul-with-amazon-ecs/
[a06]: http://gliderlabs.com/registrator/latest/
[a07]: https://sreeninet.wordpress.com/2016/04/17/service-discovery-with-consul/
[a08]: https://www.consul.io/docs/guides/bootstrapping.html
[a09]: https://www.consul.io/docs/agent/options.html#_join
[a10]: https://www.oreilly.com/ideas/an-introduction-to-immutable-infrastructure
[a12]: https://brew.sh/
[a13]: https://www.vagrantup.com/
[a14]: https://www.virtualbox.org/
[a15]: https://aws.amazon.com/quickstart/architecture/consul/
[a16]: http://www.andyfrench.info/2015/08/setting-up-consul-cluster-for-testing_15.html
[a15]: https://www.apple.com/macos/monterey/