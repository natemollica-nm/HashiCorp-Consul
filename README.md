# Vagrant Consul Cluster

A 6-Node [Consul][a01] cluster ( variant of [vagrant-consul-cluster][a16] ) with 2-node compute client resources to run services on to demonstrate how Consul works, and to learn about how it operates.

## Prerequisites

1. [macOS][a15] Macbook with macOS Monterey v12.1 or newer.
1. [Vagrant][a13] 1.9.1 or newer.
1. [VirtualBox][a14] 5.1.x.  Older versions may work, but I have not tested it.

## Cluster Architecture

The `Vagrantfile` is set up to create 6 hosts of various types as described below.

|     <font size="4"> HostName </font>      | <font size="4"> Description </font>                                                                                                                                |
|:-----------------------------------------:|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| <font size="2.5"> consul-server-x </font> | This is a 6-node Consul server cluster that is bootstrapped by the bootstrap host, and has quorum as a Consul cluster even after the `bootstrap` host is destroyed. |
| <font size="2.5"> consul-client-1 </font> | A 1-node compute cluster, each running a Consul client|


## Usage

### Cluster Creation

```
# Consul Cluster -- Vagrant Provisioning and Cleanup

# Create the Consul servers and Clients
vagrant up

# Destroy Vagrant Consul Cluster
vagrant destroy -f
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
1. [Vagrant Consul Cluster GitHub Repo: vagrant-consul-cluster][a16]

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
[a16]: https://github.com/infrastructure-as-code/vagrant-consul-cluster