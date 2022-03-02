# -*- mode: ruby -*-
# vi: set ft=ruby :

def create_vm config, host, prov_script, scrpt_args
    # VB Hostname
    config.vm.hostname = host["hostname"]

    # VB Host IP
    config.vm.network :private_network, ip: host["ip"]

    # Using HashiCorps Bionic64 Base VB Image
    config.vm.box = "hashicorp/bionic64"

    config.vm.provision "shell" do |s|
        s.path = prov_script
        s.args = [scrpt_args]
    end

    config.vm.provision "shell",
        inline: "exec consul agent -config-file=/etc/consul.d/config.json -client '{{ GetPrivateInterfaces | exclude \"type\" \"ipv6\" | join \"address\" \" \" }}' -advertise=#{host["ip"]} -bind '{{ GetInterfaceIP \"eth1\" }}' -data-dir=\"var/consul\" -dev -node ${HOSTNAME}"
end

Vagrant.configure(2) do |config|

    # Consul Bootstrap Server Node .10 IP
    [
        {
            "hostname" => "bootstrap",
            "ip" => "192.168.56.10",
        }
    ].each do |host|
        config.vm.define host["hostname"] do |config|
            config_script = "./provisioning/server.sh"
            node_config = "/vagrant/configs/node_configs/bootstrap_config.json"
            create_vm(config, host, config_script, node_config)
        end
    end

    # Consul Server Cluster (Non-Bootstraps) .11-.13 IPs
    (1..3).each do |id|
        base_ip = 10
        host = {
            "hostname" => "consul-%02d" % [id],
            "ip" => "192.168.56.%d" % [base_ip + id],
        }
        config.vm.define host["hostname"] do |config|
            config_script = "./provisioning/server.sh"
            node_config = "/vagrant/configs/node_configs/consul_srv_config.json"
            create_vm(config, host, config_script, node_config)
        end
    end

    # Consul Clients .21-.22 IP
    (1..2).each do |id|
        base_ip = 20
        host = {
            "hostname" => "client-%02d" % [id],
            "ip" => "192.168.56.%d" % [base_ip + id],
        }
        config.vm.define host["hostname"] do |config|
            config_script = "./provisioning/client.sh"
            node_config = "/vagrant/configs/node_configs/consul_clnt_config.json"
            create_vm(config, host, config_script, node_config)
        end
    end
end
