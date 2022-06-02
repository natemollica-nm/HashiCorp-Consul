# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

CONSUL_VERSION="1.11.5+ent"
LAN_IP_DC1="20.0.0"
LAN_IP_DC2="20.1.0"
WAN_IP="192.168.0"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "hashicorp/bionic64" # Ubuntu 18.04 LTS 64-bit Box
  config.vm.provider "virtualbox" do |v|
    v.memory = "1024"
   end

    config.vm.define "consul-cluster-router" do |router|
      router.vm.network "private_network", ip: "#{LAN_IP_DC1}.1"
      router.vm.network "private_network", ip: "#{LAN_IP_DC2}.1"
      router.vm.network "public_network", ip: "#{WAN_IP}.101", bridge: "bridge0"
      router.vm.provision "shell", path: "scripts/vagrant-routing/ubuntu-router-configure.sh", run: "always",
        args: "'--router-ip' #{WAN_IP}.1"
      router.vm.provision :reload
    end

    config.vm.define "consul-dc1-server-0" do |consul0|
        consul0.vm.provision "shell", path: "prov/install-consul", run: "always",
            args: "'--version' #{CONSUL_VERSION} '--datacenter' 'dc1' '--bootstrap-acls' '--enable-acls' '--enable-consul-connect' '--set-gossip-encryption' '--set-rpc-encryption'"
        consul0.vm.hostname = "consul-dc1-server-0"
        consul0.vm.network "private_network", ip: "#{LAN_IP_DC1}.10"
        consul0.vm.network "public_network", ip: "#{WAN_IP}.100", bridge: "bridge0"
        consul0.vm.network "forwarded_port", guest: 8500, host: 8500, protocol: "tcp"
        consul0.vm.provision "shell", path: "scripts/vagrant-routing/consul-node-routing.sh", run: "always",
            args: "'--local-lan' #{LAN_IP_DC1} '--remote-lan' #{LAN_IP_DC2} '--wan-net' #{WAN_IP}"
    end

    config.vm.define "consul-dc1-server-1" do |consul1|
        consul1.vm.provision "shell", path: "prov/install-consul", run: "always",
            args: "'--version' #{CONSUL_VERSION} '--datacenter' 'dc1' '--enable-acls' '--enable-consul-connect' '--set-gossip-encryption' '--set-rpc-encryption'"
        consul1.vm.hostname = "consul-dc1-server-1"
        consul1.vm.network "private_network", ip: "#{LAN_IP_DC1}.20"
        consul1.vm.network "public_network", ip: "#{WAN_IP}.150", bridge: "bridge0"
        consul1.vm.provision "shell", path: "scripts/vagrant-routing/consul-node-routing.sh", run: "always",
            args: "'--local-lan' #{LAN_IP_DC1} '--remote-lan' #{LAN_IP_DC2} '--wan-net' #{WAN_IP}"
    end

    config.vm.define "consul-dc1-server-2" do |consul2|
        consul2.vm.provision "shell", path: "prov/install-consul", run: "always",
            args: "'--version' #{CONSUL_VERSION} '--datacenter' 'dc1' '--enable-acls' '--enable-consul-connect' '--set-gossip-encryption' '--set-rpc-encryption'"
        consul2.vm.hostname = "consul-dc1-server-2"
        consul2.vm.network "private_network", ip: "#{LAN_IP_DC1}.30"
        consul2.vm.network "public_network", ip: "#{WAN_IP}.160", bridge: "bridge0"
        consul2.vm.provision "shell", path: "scripts/vagrant-routing/consul-node-routing.sh", run: "always",
            args: "'--local-lan' #{LAN_IP_DC1} '--remote-lan' #{LAN_IP_DC2} '--wan-net' #{WAN_IP}"
    end

    config.vm.define "consul-dc1-server-3" do |consul3|
        consul3.vm.provision "shell", path: "prov/install-consul", run: "always",
            args: "'--version' #{CONSUL_VERSION} '--datacenter' 'dc1' '--bootstrap-acls' '--enable-acls' '--enable-consul-connect' '--set-gossip-encryption' '--set-rpc-encryption'"
        consul3.vm.hostname = "consul-dc1-server-3"
        consul3.vm.network "private_network", ip: "#{LAN_IP_DC1}.40"
        consul3.vm.network "public_network", ip: "#{WAN_IP}.165", bridge: "bridge0"
        consul3.vm.provision "shell", path: "scripts/vagrant-routing/consul-node-routing.sh", run: "always",
            args: "'--local-lan' #{LAN_IP_DC1} '--remote-lan' #{LAN_IP_DC2} '--wan-net' #{WAN_IP}"
    end

    config.vm.define "consul-dc1-mesh-gw" do |primary_mesh|
        primary_mesh.vm.provision "shell", path: "prov/install-consul", run: "always",
            args: "'--version' #{CONSUL_VERSION} '--datacenter' 'dc1' '--bootstrap-acls' '--enable-acls' '--enable-consul-connect' '--enable-primary-mesh-gateway' '--set-gossip-encryption' '--set-rpc-encryption'"
        primary_mesh.vm.hostname = "consul-dc1-mesh-gw"
        primary_mesh.vm.network "private_network", ip: "#{LAN_IP_DC1}.55"
        primary_mesh.vm.network "public_network", ip: "#{WAN_IP}.155", bridge: "bridge0"
        primary_mesh.vm.network "forwarded_port", guest: 19000, host: 19000, protocol: "tcp"
        primary_mesh.vm.provision "shell", path: "scripts/vagrant-routing/consul-node-routing.sh", run: "always",
            args: "'--local-lan' #{LAN_IP_DC1} '--remote-lan' #{LAN_IP_DC2} '--wan-net' #{WAN_IP}"
    end

    config.vm.define "consul-dc1-client-0" do |client0|
        client0.vm.provision "shell", path: "prov/install-consul", run: "always",
            args: "'--version' #{CONSUL_VERSION} '--datacenter' 'dc1' '--enable-acls' '--set-gossip-encryption' '--set-rpc-encryption'"
        client0.vm.hostname = "consul-dc1-client-0"
        client0.vm.network "private_network", ip: "#{LAN_IP_DC1}.2"
        client0.vm.network "public_network", ip: "#{WAN_IP}.200", bridge: "bridge0"
        client0.vm.provision "shell", path: "scripts/vagrant-routing/consul-node-routing.sh", run: "always",
            args: "'--local-lan' #{LAN_IP_DC1} '--remote-lan' #{LAN_IP_DC2} '--wan-net' #{WAN_IP}"
    end

    config.vm.define "consul-dc1-client-1" do |client1|
        client1.vm.provision "shell", path: "prov/install-consul", run: "always",
            args: "'--version' #{CONSUL_VERSION} '--datacenter' 'dc1' '--enable-acls' '--set-gossip-encryption' '--set-rpc-encryption'"
        client1.vm.hostname = "consul-dc1-client-1"
        client1.vm.network "private_network", ip: "#{LAN_IP_DC1}.3"
        client1.vm.network "public_network", ip: "#{WAN_IP}.201", bridge: "bridge0"
        client1.vm.provision "shell", path: "scripts/vagrant-routing/consul-node-routing.sh", run: "always",
            args: "'--local-lan' #{LAN_IP_DC1} '--remote-lan' #{LAN_IP_DC2} '--wan-net' #{WAN_IP}"
    end

    config.vm.define "consul-dc2-server-0" do |consul20|
        consul20.vm.provision "shell", path: "prov/install-consul", run: "always",
            args: "'--version' #{CONSUL_VERSION} '--datacenter' 'dc2' '--enable-acls' '--enable-consul-connect' '--set-gossip-encryption' '--set-rpc-encryption'"
        consul20.vm.hostname = "consul-dc2-server-0"
        consul20.vm.network "private_network", ip: "#{LAN_IP_DC2}.10"
        consul20.vm.network "public_network", ip: "#{WAN_IP}.170", bridge: "bridge0"
        consul20.vm.network "forwarded_port", guest: 8501, host: 8501, protocol: "tcp"
        consul20.vm.provision "shell", path: "scripts/vagrant-routing/consul-node-routing.sh", run: "always",
            args: "'--local-lan' #{LAN_IP_DC2} '--remote-lan' #{LAN_IP_DC1} '--wan-net' #{WAN_IP}"
    end

    config.vm.define "consul-dc2-server-1" do |consul21|
        consul21.vm.provision "shell", path: "prov/install-consul", run: "always",
            args: "'--version' #{CONSUL_VERSION} '--datacenter' 'dc2' '--enable-acls' '--enable-consul-connect' '--set-gossip-encryption' '--set-rpc-encryption'"
        consul21.vm.hostname = "consul-dc2-server-1"
        consul21.vm.network "private_network", ip: "#{LAN_IP_DC2}.20"
        consul21.vm.network "public_network", ip: "#{WAN_IP}.180", bridge: "bridge0"
        consul21.vm.provision "shell", path: "scripts/vagrant-routing/consul-node-routing.sh", run: "always",
            args: "'--local-lan' #{LAN_IP_DC2} '--remote-lan' #{LAN_IP_DC1} '--wan-net' #{WAN_IP}"
    end

    config.vm.define "consul-dc2-server-2" do |consul22|
        consul22.vm.provision "shell", path: "prov/install-consul", run: "always",
            args: "'--version' #{CONSUL_VERSION} '--datacenter' 'dc2' '--enable-acls' '--enable-consul-connect' '--set-gossip-encryption' '--set-rpc-encryption'"
        consul22.vm.hostname = "consul-dc2-server-2"
        consul22.vm.network "private_network", ip: "#{LAN_IP_DC2}.30"
        consul22.vm.network "public_network", ip: "#{WAN_IP}.190", bridge: "bridge0"
        consul22.vm.provision "shell", path: "scripts/vagrant-routing/consul-node-routing.sh", run: "always",
            args: "'--local-lan' #{LAN_IP_DC2} '--remote-lan' #{LAN_IP_DC1} '--wan-net' #{WAN_IP}"
    end

    config.vm.define "consul-dc2-server-3" do |consul23|
        consul23.vm.provision "shell", path: "prov/install-consul", run: "always",
            args: "'--version' #{CONSUL_VERSION} '--datacenter' 'dc2' '--enable-acls' '--enable-consul-connect'  '--set-gossip-encryption' '--set-rpc-encryption'"
        consul23.vm.hostname = "consul-dc2-server-3"
        consul23.vm.network "private_network", ip: "#{LAN_IP_DC2}.40"
        consul23.vm.network "public_network", ip: "#{WAN_IP}.195", bridge: "bridge0"
        consul23.vm.provision "shell", path: "scripts/vagrant-routing/consul-node-routing.sh", run: "always",
            args: "'--local-lan' #{LAN_IP_DC2} '--remote-lan' #{LAN_IP_DC1} '--wan-net' #{WAN_IP}"
    end

    config.vm.define "consul-dc2-mesh-gw" do |secondary_mesh|
      secondary_mesh.vm.provision "shell", path: "prov/install-consul", run: "always",
          args: "'--version' #{CONSUL_VERSION} '--datacenter' 'dc2' '--enable-acls' '--enable-consul-connect' '--enable-secondary-mesh-gateway' '--set-gossip-encryption' '--set-rpc-encryption'"
      secondary_mesh.vm.hostname = "consul-dc2-mesh-gw"
      secondary_mesh.vm.network "private_network", ip: "#{LAN_IP_DC2}.55"
      secondary_mesh.vm.network "public_network", ip: "#{WAN_IP}.185", bridge: "bridge0"
      secondary_mesh.vm.provision "shell", path: "scripts/vagrant-routing/consul-node-routing.sh", run: "always",
        args: "'--local-lan' #{LAN_IP_DC2} '--remote-lan' #{LAN_IP_DC1} '--wan-net' #{WAN_IP}"
    end

    config.vm.define "consul-dc2-client-0" do |client20|
        client20.vm.provision "shell", path: "prov/install-consul", run: "always",
            args: "'--version' #{CONSUL_VERSION} '--datacenter' 'dc2' '--enable-acls' '--set-gossip-encryption' '--set-rpc-encryption'"
        client20.vm.hostname = "consul-dc2-client-0"
        client20.vm.network "private_network", ip: "#{LAN_IP_DC2}.2"
        client20.vm.network "public_network", ip: "#{WAN_IP}.202", bridge: "bridge0"
        client20.vm.provision "shell", path: "scripts/vagrant-routing/consul-node-routing.sh", run: "always",
            args: "'--local-lan' #{LAN_IP_DC2} '--remote-lan' #{LAN_IP_DC1} '--wan-net' #{WAN_IP}"
    end

    config.vm.define "consul-dc2-client-1" do |client21|
        client21.vm.provision "shell", path: "prov/install-consul", run: "always",
            args: "'--version' #{CONSUL_VERSION} '--datacenter' 'dc2' '--enable-acls' '--set-gossip-encryption' '--set-rpc-encryption'"
        client21.vm.hostname = "consul-dc2-client-1"
        client21.vm.network "private_network", ip: "#{LAN_IP_DC2}.3"
        client21.vm.network "public_network", ip: "#{WAN_IP}.203", bridge: "bridge0"
        client21.vm.provision "shell", path: "scripts/vagrant-routing/consul-node-routing.sh", run: "always",
            args: "'--local-lan' #{LAN_IP_DC2} '--remote-lan' #{LAN_IP_DC1} '--wan-net' #{WAN_IP}"
    end
 end
