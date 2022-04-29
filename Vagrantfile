# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "hashicorp/bionic64"

    config.vm.define "consul-server-1" do |consul1|
        consul1.vm.provision "shell", path: "prov/provision.sh", run: "once"
        consul1.vm.hostname = "consul-server-1"
        consul1.vm.network "private_network", ip: "192.168.56.10"
    end

    config.vm.define "consul-server-2" do |consul2|
        consul2.vm.provision "shell", path: "prov/provision.sh", run: "once"
        consul2.vm.hostname = "consul-server-2"
        consul2.vm.network "private_network", ip: "192.168.56.20"
    end

    config.vm.define "consul-server-3" do |consul3|
        consul3.vm.provision "shell", path: "prov/provision.sh", run: "once"
        consul3.vm.hostname = "consul-server-3"
        consul3.vm.network "private_network", ip: "192.168.56.30"
    end

    config.vm.define "consul-server-4" do |consul4|
        consul4.vm.provision "shell", path: "prov/provision.sh", run: "once"
        consul4.vm.hostname = "consul-server-4"
        consul4.vm.network "private_network", ip: "192.168.56.40"
    end

    config.vm.define "consul-server-5" do |consul5|
        consul5.vm.provision "shell", path: "prov/provision.sh", run: "once"
        consul5.vm.hostname = "consul-server-5"
        consul5.vm.network "private_network", ip: "192.168.56.50"
    end

    config.vm.define "consul-server-6" do |consul6|
        consul6.vm.provision "shell", path: "prov/provision.sh", run: "once"
        consul6.vm.hostname = "consul-server-6"
        consul6.vm.network "private_network", ip: "192.168.56.60"
    end

    config.vm.define "consul-client-1" do |client1|
        client1.vm.provision "shell", path: "prov/provisionclient.sh", run: "once"
        client1.vm.hostname = "consul-client-1"
        client1.vm.network "private_network", ip: "192.168.56.70"
        client1.vm.network "forwarded_port", guest: 8500, host: 8500, protocol: "tcp"
    end

 end
