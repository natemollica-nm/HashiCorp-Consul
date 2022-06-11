# Vagrant VM Service Mesh (hashicorp/bionic64)
<h2>
  <img style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif; font-size: 15px;" src="https://mktg-content-api-hashicorp.vercel.app/api/assets?product=consul&version=refs%2Fheads%2Fstable-website&asset=website%2Fpublic%2F%2Fimg%2Fwan-federation-connectivity-mesh-gateways.png&width=2048&height=2403" alt="Screen_Shot_2022-06-01_at_1.18.56_PM.png">
</h2>

A 6-Node [Consul][a01] cluster ( inspired by [vagrant-consul-cluster][a16] ) for configuring and testing Consul locally.

## Prerequisites

1. [macOS][a15] MacBook Pro (Intel based architecture)
2. 16GB of RAM or greater
3. 128GB of free disk space.
4. macOS Monterey v12.1 or newer.
5. Reliable Internet Connection
6. Knowledge of internal home network IP scheme (simulated WAN network).
7. Knowledge of MacBook's usable network adapters for bridging VM network.

   ```console
   user@macbook:~$ network setup -listallhardwareports
   ```
9. Valid Consul Enterprise License if using Consul Enterprise.
10. [Vagrant][a13] 1.9.1 or newer.
11. Vagrant Reload plugin installed ([Vagrant Reload Plugin][a17])
12. [VirtualBox][a14] 5.1.x or newer

## Cluster Architecture
The `Vagrantfile` is set up to create 6 hosts of various types as described below.

<strong>Default Initial Configuration:</strong>
</h2>
<table style="border-collapse: collapse; width: 100%;" border="1">
  <tbody>
    <tr>
      <td style="width: 43.2858%;">
        <h3 class="wysiwyg-text-align-center">VM Defaults</h3>
      </td>
      <td style="width: 56.7142%;">
        <h3 class="wysiwyg-text-align-center">Consul Defaults</h3>
      </td>
    </tr>
    <tr>
      <td style="width: 43.2858%;">
        <ul>
          <li>
            OS: Ubuntu 18.04.3 LTS (bionic)
            <ul>
              <li>vCPUs - 6</li>
              <li>vMem - 2048MB (2GB)</li>
            </ul>
          </li>
          <li>
            Installed Dependencies -
            <ul>
              <li>curl</li>
              <li>wget</li>
              <li>software-properties-common</li>
              <li>jq</li>
              <li>unzip</li>
              <li>traceroute</li>
              <li>nmap</li>
              <li>socat</li>
              <li>iptables-persistent</li>
              <li>dnsmasq</li>
            </ul>
          </li>
          <li>
            Networking (Defaults) -
            <ul>
              <li>
                Primary DC Bridged:
                <ul>
                  <li>LAN: 20.0.0.0/24</li>
                  <li>WAN: 192.168.0.0/24</li>
                </ul>
              </li>
              <li>
                Secondary DC Bridged:
                <ul>
                  <li>LAN: 20.1.0.0/24</li>
                  <li>WAN: 192.168.0.0/24</li>
                </ul>
              </li>
              <li>
                Cluster VM Router Bridged:
                <ul>
                  <li>LAN1: 20.0.0.0/24</li>
                  <li>LAN2: 20.1.0.0/24</li>
                  <li>Port Forwarding/Routing Enabled</li>
                </ul>
              </li>
            </ul>
          </li>
        </ul>
      </td>
      <td style="width: 56.7142%;">
        <ul>
          <li>Consul Version: 1.11.5+ent</li>
          <li>Envoy Version: 1.20.2</li>
          <li>systemd unit file installed/configured</li>
          <li>Gossip Encryption: Enabled</li>
          <li>TLS Encryption:&nbsp; &nbsp; &nbsp; Enabled</li>
          <li>
            ACLs:&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
            &nbsp; &nbsp; &nbsp; &nbsp;Enabled/Bootstrapped
          </li>
          <li>
            Primary DC Server Roles
            <ul>
              <li>
                consul-dc1-server-0:&nbsp; Cluster Certificate Authority
                (Consul CA)
              </li>
              <li>
                consul-dc1-server-1:&nbsp; &nbsp;Cluster Member Server
                Hosting Dashboard Service
              </li>
              <li>consul-dc1-mesh-gw: Cluster Mesh Gateway (Primary)</li>
            </ul>
          </li>
          <li>
            Secondary DC Server Roles
            <ul>
              <li>consul-dc2-server-0:&nbsp; Cluster Member Server</li>
              <li>
                consul-dc2-server-1:&nbsp; &nbsp;Cluster Member Server
                Hosting Dashboard Service
              </li>
              <li>consul-dc2-mesh-gw: Cluster Mesh Gateway (Secondary)</li>
            </ul>
          </li>
        </ul>
      </td>
    </tr>
  </tbody>
</table>


### Configuring Prerequisites

## VirtualBox Private Network Configuration
```/etc/vbox/networks.conf```

VirtualBox utilizes a preset *192.168.65.0/24* networking scheme.

In order to allow for alternative networking configurations (i.e., the kind required by this repository), please ensure of the following:

1. Create VirtualBox ```networks.conf```
   ```console
   sudo mkdir -p /etc/vbox
   sudo touch /etc/vbox/networks.conf
   ```

2. Edit the networks.conf (nano/vim) file to encompass the required networks. 
   
    *Note: adjust the first CIDR addressing to match your home networking scheme.*
   ```vim
   * 192.168.0.0/24 192.168.65.0/24 20.0.0.0/24 20.1.0.0/24
   ```
3. Save the networks.conf file as applicable by your editor (nano/vim).
4. Restart the VirtualBox application to apply changes.

# Cluster Creation

1. Clone the Vagrant Consul Cluster repository to a working directory you desire.
 
   ```console
   git clone https://github.com/natemollica-nm/vagrant-consul-cluster
   ```


2. Initialize Vagrant environment.

   ```console
   vagrant init
   ```


4. If applicable, edit the imported ```Vagrantfile``` variables for

   ```ruby
   CONSUL_VERSION="1.11.5+ent"
   ENVOY_VERSION="1.20.2"
   LAN_IP_DC1="20.0.0"
   LAN_IP_DC2="20.1.0"
   WAN_IP="192.168.0"
   MAC_NETWORK_BRIDGE="en0: Wi-Fi"
   ```
   *Note: These variables can be set to configure the Consul Version, Envoy Version, and LAN and WAN specifics of your desired configuration.*
   *Ensure your simulated WAN IP CIDR corresponds to your home specific network configuration and your MAC_NETWORK_BRIDGE is set to
   your desired network adapter.
   Ensure the Consul-Envoy versions being used are in accordance with HashiCorp's supported versioning found*
   *at* https://www.consul.io/docs/connect/proxies/envoy


6. (Optional) Append the anticipated cluster host IPs to your ```/etc/hosts``` file to promote a faster provisioning process.

   ```console
   # LAN IPs
   20.0.0.10 consul-dc1-server-0
   20.0.0.20 consul-dc1-server-1
   20.0.0.30 consul-dc1-server-2
   20.0.0.40 consul-dc1-server-3
   20.0.0.55 consul-dc1-mesh-gw
   20.1.0.10 consul-dc2-server-0
   20.1.0.20 consul-dc2-server-1
   20.1.0.30 consul-dc2-server-2
   20.1.0.40 consul-dc2-server-3
   20.1.0.55 consul-dc2-mesh-gw
   # WAN IPs
   192.168.0.100 consul-dc1-server-0
   192.168.0.150 consul-dc1-server-1
   192.168.0.160 consul-dc1-server-2
   192.168.0.165 consul-dc1-server-3
   192.168.0.170 consul-dc2-server-0
   192.168.0.180 consul-dc2-server-1
   192.168.0.190 consul-dc2-server-2
   192.168.0.195 consul-dc2-server-3
   192.168.0.155 consul-dc1-mesh-gw
   192.168.0.185 consul-dc2-mesh-gw
   ```

7. Start the Consul cluster Ubuntu Router and Primary DC provisioning process.

   ```console
   vagrant up consul-cluster-router consul-dc1-server-0 consul-dc1-server-1 consul-dc1-mesh-gw
   ```

8. Monitor provisioning of Primary DC until completion.

9. Start the Consul cluster Secondary DC provisioning process

   ```console
   vagrant up consul-dc2-server-0 consul-dc2-server-1 consul-dc2-mesh-gw
   ```

10. Monitor provisioning of Secondary DC until completion.

## Vagrant Cluster Removal

Destroy all Vagrant VirtualBox VMs

   ```console
   vagrant destroy -f
   ```

## References

1. [Consul Documentation][a01]
1. [WAN Federation via Mesh Gateways][a02]
1. [Setting up a Consul cluster for testing and development with Vagrant (Part 2)][a16]

[a01]: https://www.consul.io/
[a02]: https://www.consul.io/docs/connect/gateways/mesh-gateway/wan-federation-via-mesh-gateways
[a13]: https://www.vagrantup.com/
[a14]: https://www.virtualbox.org/
[a16]: http://www.andyfrench.info/2015/08/setting-up-consul-cluster-for-testing_15.html
[a15]: https://www.apple.com/macos/monterey/
[a16]: https://github.com/infrastructure-as-code/vagrant-consul-cluster
[a17]: https://github.com/aidanns/vagrant-reload