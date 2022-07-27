# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
DATACENTERS=1
CONSUL_CLIENTS=1
CONSUL_SERVERS=1
CONSUL_VERSION="1.11.7+ent"
ENVOY_VERSION="1.19.3"
VAULT_VERSION="1.8.9+ent"
WAN_CIDR="192.169.7"
MAC_NETWORK_BRIDGE="en6: AX88179A"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  1.upto(DATACENTERS) do |i|
    0.upto(CONSUL_SERVERS - 1) do |n|
      config.vm.define "consul-dc#{i}-server-#{n}" do |server|
        server.vm.box = "hashicorp/bionic64"
        server.vm.hostname = "consul-dc#{i}-server-#{n}"
        server.vm.network "private_network", ip: "#{i}0.0.0.#{i}#{n}", bridge: "#{MAC_NETWORK_BRIDGE}"
        server.vm.network "private_network", ip: "#{WAN_CIDR}.#{i}#{n}", bridge: "#{MAC_NETWORK_BRIDGE}"

        if n == 0 && i == 1
          server.vm.network "forwarded_port", guest: 8500, host: 8500, auto_correct: true, host_ip: "127.0.0.1"
          server.vm.provision "shell", path: "scripts/configure-os/configure-os", privileged: true, run: "once", env: { "DATACENTER": "dc#{i}" }
          server.vm.provision "shell", path: "scripts/env/env-hosts-file", privileged: true, run: "once", env: { "DATACENTER": "dc#{i}" }
          server.vm.provision "shell", path: "scripts/install-consul/install-consul", privileged: true, run: "once",
            env: { "DATACENTER": "dc#{i}", "CONSUL_VERSION": "#{CONSUL_VERSION}", "ENVOY_VERSION": "#{ENVOY_VERSION}", "BOOTSTRAP": "#{CONSUL_SERVERS}", "DATACENTERS": "#{DATACENTERS}" },
            args: "'--enable-consul-ui' '--update-gossip-key' '--set-gossip-encryption' '--enable-acls'"
#           server.vm.provision "shell", path: "scripts/tls/consul-tls-configure", privileged: true, run: "once",
#             env: { "CONSUL_VERSION": "#{CONSUL_VERSION}", "DATACENTER": "dc#{i}" },
#             args: "'--cert-authority-init' '--set-rpc-encryption'"
        else
          server.vm.provision "shell", path: "scripts/configure-os/configure-os", privileged: true, run: "once", env: { "DATACENTER": "dc#{i}" }
          server.vm.provision "shell", path: "scripts/env/env-hosts-file", privileged: true, run: "once", env: { "DATACENTER": "dc#{i}" }
          server.vm.provision "shell", path: "scripts/install-consul/install-consul", privileged: true, run: "once",
            env: { "DATACENTER": "dc#{i}", "CONSUL_VERSION": "#{CONSUL_VERSION}", "ENVOY_VERSION": "#{ENVOY_VERSION}", "BOOTSTRAP": "#{CONSUL_SERVERS}" },
            args: "'--enable-consul-ui' '--set-gossip-encryption' '--enable-acls'"
#           server.vm.provision "shell", path: "scripts/tls/consul-tls-configure", privileged: true, run: "once",
#             env: { "CONSUL_VERSION": "#{CONSUL_VERSION}", "DATACENTER": "dc#{i}" },
#             args: "'--set-rpc-encryption'"
        end

        server.vm.provider "virtualbox" do |vb|
          vb.cpus = 6
          vb.memory = "4096"
        end
      end
    end
  end
  1.upto(DATACENTERS) do |i|
    0.upto(CONSUL_CLIENTS - 1) do |n|
      config.vm.define "consul-dc#{i}-client-#{n}" do |client|
        client.vm.box = "hashicorp/bionic64"
        client.vm.hostname = "consul-dc#{i}-client-#{n}"
        client.vm.network "private_network", ip: "#{i}0.0.0.#{i}#{n}1", bridge: "#{MAC_NETWORK_BRIDGE}"
        client.vm.network "private_network", ip: "#{WAN_CIDR}.#{i}#{n}1", bridge: "#{MAC_NETWORK_BRIDGE}"

        client.vm.provision "shell", path: "scripts/configure-os/configure-os", privileged: true, run: "once", env: { "DATACENTER": "dc#{i}" }
        client.vm.provision "shell", path: "scripts/env/env-hosts-file", privileged: true, run: "once", env: { "DATACENTER": "dc#{i}" }
        client.vm.provision "shell", path: "scripts/install-consul/install-consul", privileged: true, run: "once",
          env: { "DATACENTER": "dc#{i}", "CONSUL_VERSION": "#{CONSUL_VERSION}", "ENVOY_VERSION": "#{ENVOY_VERSION}" },
          args: "'--enable-consul-ui' '--set-gossip-encryption' '--enable-acls'"
#         client.vm.provision "shell", path: "scripts/tls/consul-tls-configure", privileged: true, run: "once",
#           env: { "CONSUL_VERSION": "#{CONSUL_VERSION}", "DATACENTER": "dc#{i}" },
#           args: "'--set-rpc-encryption'"
        client.vm.provision "shell", path: "scripts/install-vault/install-vault", privileged: true, run: "once",
          env: { "VAULT_VERSION": "#{VAULT_VERSION}", "DATACENTER": "dc#{i}" }
        client.vm.provision "shell", path: "scripts/install-vault/initialize-vault", privileged: true, run: "once"

        client.vm.provider "virtualbox" do |vb|
          vb.cpus = 6
          vb.memory = "4096"
        end
      end
    end
 end
end