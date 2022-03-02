# Vagrant Consul Cluster

A 3-node [Consul][a01] cluster with 2-node compute client resources to run services on to demonstrate how Consul works, and to learn about how it operates.

## Prerequisites

1. [Vagrant][a13] 1.9.1 or newer.
1. [VirtualBox][a14] 5.1.x.  Older versions may work, but I have not tested it.

## Cluster Architecture

The `Vagrantfile` is set up to create 6 hosts of various types as described below.

| Hostname | Description |
|----------|-------------|
| `bootstrap` | This is the first Consul server that is started in bootstrap mode to expect 2 more Consul servers to join the server cluster.  Its sole purpose is to bootstrap the Consul cluster, after which it can be destroyed. |
| `consul-0[1-3]` | This is a 3-node Consul server cluster that is bootstrapped by the bootstrap host, and has quorum as a Consul cluster even after the `bootstrap` host is destroyed. |
| `compute-0[1-2]` | A 2-node compute cluster, each running a Consul client, Docker and [Registrator][a06] to update the location of services running on them. |


## Usage

### Cluster Creation

```
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

### Registering Services

```
# Log on to the client-01 node
vagrant ssh client-01

# Run the Hello World container
docker run \
  --detach \
  --publish 80 \
  --env SERVICE_80_NAME=hello-world \
  --env SERVICE_80_CHECK_SCRIPT='curl --silent --fail http://0.0.0.0:$SERVICE_PORT/health' \
  --env SERVICE_80_CHECK_INTERVAL=5s \
  --env SERVICE_80_CHECK_TIMEOUT=3s \
  --env SERVICE_TAGS=http \
  infrastructureascode/hello-world

# Look up its Consul DNS name with the SRV record
dig SRV hello-world.service.dc1.consul

# Log on to the client-02 node
vagrant ssh client-02

# Run another copy of the Hello World container
docker run \
  --detach \
  --publish 80 \
  --env SERVICE_80_NAME=hello-world \
  --env SERVICE_80_CHECK_SCRIPT='curl --silent --fail http://0.0.0.0:$SERVICE_PORT/health' \
  --env SERVICE_80_CHECK_INTERVAL=5s \
  --env SERVICE_80_CHECK_TIMEOUT=3s \
  --env SERVICE_TAGS=http \
  infrastructureascode/hello-world

# Look up its Consul DNS again and see the SRV record resolve to two instances,
# with one instance on each compute node.
dig SRV hello-world.service.dc1.consul
```

### Simulating Consul Outages

```
# Destroy any Consul server, or the Consul leader, and watch the cluster react.
vagrant destroy consul-03
```

## FAQ

### What does the bootstrap server do, and why can it be destroyed after the rest of the Consul servers come online?

The Consul start-up command is hard-coded to [bootstrap][a08] the Consul cluster, while the rest of the 3-node Consul servers are told to [join][a09] an agent in an existing Consul cluster.  Since the bootstrap server is hard-coded to bootstrap, it has outlived its function after the bootstrap process unless its hard-coded command is updated.  However, since I try to build only [immutable infrastructure][a10], updating the command on the bootstrap host would be less than ideal, so I just destroy it instead since the rest of the servers are already bootstrapped, and can come and go without the operations of the cluster getting impacted as long as we maintain a quorum online.

### Should I use this setup in my production environment?

Each production environment is slightly different since needs vary widely.  This Vagrant setup is created as a means to create aConsul cluster that can be used as a starting point to learn about how to operate such a cluster, and may or may not be appropriate for your production environment as is.  Make sure you factor in your needs!


## References

1. [Consul documentation][a01]
1. [Wicked Awesome Tech: Setting up Consul Service Discovery for Mesos in 10 Minutes][a02]
1. [Get Docker for Ubuntu][a03]
1. [kelseyhightower/setup-network-environment][a04]
1. [AWS Compute Blog: Service Discovery via Consul with Amazon ECS][a05]
1. [gliderlabs/registrator][a06]
1. [Sreenivas Makam's Blog: Service Discovery with Consul][a07]
1. [tomkins/cloud-init-vagrant][a15]
1. [AWS Quick Starts: HashiCorp Consul on AWS][a16]

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
[a11]: https://cloudinit.readthedocs.io/en/latest/
[a12]: https://brew.sh/
[a13]: https://www.vagrantup.com/
[a14]: https://www.virtualbox.org/
[a15]: https://github.com/tomkins/cloud-init-vagrant
[a16]: https://aws.amazon.com/quickstart/architecture/consul/