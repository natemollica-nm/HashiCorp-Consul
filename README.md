# Vagrant VM Service Mesh using Envoy Proxy
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

   ```zsh
   user@macbook:~$ network setup -listallhardwareports
   ```
9. Valid Consul Enterprise License if using Consul Enterprise.
10. [Vagrant][a13] 1.9.1 or newer.
11. Vagrant Reload plugin installed ([Vagrant Reload Plugin][a17])
12. [VirtualBox][a14] 5.1.x or newer

## Cluster Architecture
The `Vagrantfile` is set up to create 6 hosts of various types as described below.

## **Initial Configuration:**

### Virtual Machine

```zsh
OS:    Ubuntu 18.04.3 LTS (bionic)
vCPUs: 6
vMem:  4096MB (4GB)
Apt Packages Installed:
  curl, wget, software-properties-common, jq, unzip
    traceroute, nmap, socat, iptables-persistent, dnsmasq,
    netcat
    
Networking:

  Consul VMs:
     iptables: Consul Required ports/protocols allowed
     ipv4 ICMP redirects: disabled
     ipv4 Routing: LAN/WAN default routes set to cluster Ubuntu VM Router
     
  Vagrant Forwarded Ports:
       consul-dc1-server-0: 8500 --> 8500 (Consul UI)
       consul-dc2-server-0: 8500 --> 9500 (Consul UI)
       consul-dc1-mesh-gw:  19000 -> 19001 (Envoy Admin UI)
       consul-dc2-mesh-gw:  19000 -> 19002 (Envoy Admin UI)
       
  Primary DC Bridged Network:
      eth1: 20.0.0.0/16
      eth2: 192.169.7.0/24
      
  Secondary DC Bridged Network:
      eth1: 30.0.0.0/16
      eth2: 192.169.7.0/24
      
  Cluster VM Router Bridged:
      eth1: 20.0.0.0/16
      eth2: 30.0.0.0/16
      eth3: 192.169.7.0/24
      ipv4 Forwarding: Enabled (eth1-eth3)
      
  DNS: 
     dnsmasq: installed/configured 
     /etc/hosts: Consul VM local LAN and remote WAN IPs configured
```

### Consul

```zsh
Consul Version: 1.11.5+ent
Envoy Version:  1.20.2
Consul Daemon:  systemd unit file installed/configured

Log Level:             TRACE
UI:                    Enabled (consul-dc1/dc2-server-0 only)
Data Directory:        /opt/consul/data
Gossip Encryption:     Enabled
TLS Encryption:        Enabled
ACLs:                  Enabled/Bootstrapped
Connect:               Enabled
gRPC Port:             Enabled/8502
Client ipv4:           0.0.0.0
Bind ipv4:             0.0.0.0
Advertise ipv4:        eth1
Advertise ipv4 (WAN):  eth2
Translate WAN Address: Enabled
Leave on Terminate:    Enabled
Central Service Cfg:   Enabled
Proxy Defaults (Global):
    Mesh GW: Local
    Checks Exposed: true
    
Primary DC Server Roles
    consul-dc1-server-0: Cluster Certificate Authority (Consul CA)
    consul-dc1-server-1: Cluster Member Server
    consul-dc1-mesh-gw:  Cluster Mesh Gateway (Primary)
Secondary DC Server Roles
  consul-dc2-server-0: Cluster Member Server
  consul-dc2-server-1: Cluster Member Server
  consul-dc2-mesh-gw:  Cluster Mesh Gateway (Secondary)
```



### Configuring Prerequisites

## VirtualBox Private Network Configuration
```/etc/vbox/networks.conf```

VirtualBox utilizes a preset *192.168.65.0/24* networking scheme.

In order to allow for alternative networking configurations (i.e., the kind required by this repository), please ensure of the following:

1. Create VirtualBox ```networks.conf```
   ```zsh
   sudo mkdir -p /etc/vbox
   sudo touch /etc/vbox/networks.conf
   ```

2. Edit the networks.conf (nano/vim) file to encompass the required networks. 

   ```vim
   * 20.0.0.0/16 30.0.0.0/16 192.168.59.0/24 192.169.7.0/24
   ```
3. Save the networks.conf file as applicable by your editor (nano/vim).
4. Restart the VirtualBox application to apply changes.

# Cluster Creation

1. Clone the Vagrant Consul Cluster repository to a working directory you desire.
 
   ```zsh
   git clone https://github.com/natemollica-nm/vagrant-consul-cluster
   ```


2. Initialize Vagrant environment.

   ```zsh
   vagrant init
   ```


4. If applicable, edit the imported ```Vagrantfile``` variables for

   ```ruby
   CONSUL_VERSION="1.11.5+ent"
   ENVOY_VERSION="1.20.2"
   LAN_IP_DC1="20.0.0"
   LAN_IP_DC2="30.0.0"
   WAN_IP="192.169.7"
   MAC_NETWORK_BRIDGE="en0: Wi-Fi"
   ```
   *Note: These variables can be set to configure the Consul Version, Envoy Version, and LAN and WAN specifics of your desired configuration.*
   Ensure the Consul-Envoy versions being used are in accordance with HashiCorp's supported versioning found*
   *at* https://www.consul.io/docs/connect/proxies/envoy


6. (Optional) Append the anticipated cluster host IPs to your ```/etc/hosts``` file to promote a faster provisioning process.

   ```ruby
   # LAN IPs
   20.0.0.10 consul-dc1-server-0
   20.0.0.20 consul-dc1-server-1
   20.0.0.30 consul-dc1-server-2
   20.0.0.40 consul-dc1-server-3
   20.0.0.55 consul-dc1-mesh-gw
   30.0.0.10 consul-dc2-server-0
   30.0.0.20 consul-dc2-server-1
   30.0.0.30 consul-dc2-server-2
   30.0.0.40 consul-dc2-server-3
   30.0.0.55 consul-dc2-mesh-gw
   # WAN IPs
   192.168.0.110 consul-dc1-server-0
   192.168.0.120 consul-dc1-server-1
   192.168.0.130 consul-dc1-server-2
   192.168.0.140 consul-dc1-server-3
   192.168.0.150 consul-dc2-mesh-gw
   192.168.0.210 consul-dc2-server-0
   192.168.0.220 consul-dc2-server-1
   192.168.0.230 consul-dc2-server-2
   192.168.0.240 consul-dc2-server-3
   192.168.0.250 consul-dc2-mesh-gw
   ```

7. Start the Consul cluster Ubuntu Router and Primary DC provisioning process.

   ```zsh
   vagrant up consul-cluster-router consul-dc1-server-0 consul-dc1-server-1 consul-dc1-mesh-gw
   ```

8. Monitor provisioning of Primary DC until completion.

9. Start the Consul cluster Secondary DC provisioning process

   ```zsh
   vagrant up consul-dc2-server-0 consul-dc2-server-1 consul-dc2-mesh-gw
   ```

10. Monitor provisioning of Secondary DC until completion.

### Consul Environmental Variables


*Note: The following commands below are placed here for convenience in setting the Consul environmental variables*
*that are required to perform steps in this guide. Set the dc variable as applicable to the appropriate datacenter,*
*and the initial_management_token_value to the cluster's bootstrapped ACL token prior to running the commands. The ACL*
*initial bootstrap token can be located by running the below command and retrieving the acl stanza initial bootstrap token UUID value.*

   ```zsh
   cat /etc/consul.d/consul.hcl
   ```
#### Consul Environmental Variable Export

   ```ruby
   dc="dc1"
   export CONSUL_HTTP_SSL=true
   export CONSUL_HTTP_ADDR="https://127.0.0.1:8501"
   export CONSUL_CACERT="/etc/consul.d/tls/consul-agent-ca.pem"
   export CONSUL_CLIENT_CERT="/etc/consul.d/tls/$dc-server-consul-0.pem"
   export CONSUL_CLIENT_KEY="/etc/consul.d/tls/$dc-server-consul-0-key.pem"
   export CONSUL_HTTP_TOKEN=<initial_management_token_value>
   ```

### Rolling Reboot Procedure

*The Consul rolling reboot procedure will be utilized several times within this process. When required, perform the following to accomplish a rolling reboot of the desired servers to help maintain proper quorum. This should be run from one server at a time individually.*


1. Run the following and wait for Graceful Leave return message:

   ```zsh
   consul leave
   ```
2. Run the following to restart Consul daemon:

   ```zsh
   sudo service consul start
   ```
3. Ensure Consul member recognizes server as a voting member (run as required until voter is true)
    ```zsh
   consul operator raft list-peers
   ```
4. Proceed to next server until all DC servers have been Consul rebooted.

### WAN Federation (Basic)

<h4>
  <span class="wysiwyg-font-size-medium">**Note: Basic WAN Federation is not necessarily a requirement to establish WAN Federation via Mesh GWs. This is setup to allow for initial ACL replication to replicate Mesh GW ACL Tokens to both DCs. WAN Federation, when established via Mesh GWs, will in fact disable basic WAN Federation capabilities within Consul.**</span>
</h4>

1. From **consul-dc1-server-0** run:

   ```zsh
   consul join -wan "consul-dc2-server-0"
   ```

2. From **consul-dc2-server-0** run:

   ```zsh
   consul join -wan "consul-dc1-server-0"
   ```

3. Verify **DC1**and **DC2** WAN Consul Membership
  by running (on both **DC1** and **DC2**):

   ```zsh
   consul members -wan
   ```


### Configure ACL Token Replication

<p>Note: This should be run from any server in DC1.</p>

 1. If necessary, establish Consul environmental variables for variables outlined
 in section titled *Consul Environmental Variables*.

 2. Create the ACL Token replication policy by running:

    ```zsh
      repl_policy="replication-policy.hcl"
      replication_policy_rules=""
      replication_policy_rules=$( cat-CONFIG
         acl = "write"
         operator = "write"
         service_prefix "" {
            policy = "read"
            intentions = "read"
        }
      CONFIG
      )
      sudo touch $repl_policy && sudo chmod 0755 $repl_policy
      echo -e "$replication_policy_rules" | sudo tee $repl_policy
      consul acl policy create -name replication -rules @$repl_policy
      ```
   

 4. Create ACL Replication token by running:

   ```zsh
   consul acl token create -description "replication token" -policy-name replication
   ```

 6. Take note of ACL Replication token *SecretID*. In <span class="wysiwyg-underline">***ALL*** ***DC2*** servers ensure consul.hcl (*/etc/consul.d/consul.hcl*)
 configuration files have the following entries for ACL replication and Primary DC designation:

   ```zsh
   primary_datacenter = "dc1"
   acl {
      enabled = true
      default_policy = "allow"
      enable_token_replication = true
      enable_token_persistence = true
      tokens {
         initial_management = <initial_mgmt_token>
         replication        = <replication_token_secretID>
      }
   }
   ```
 
 8. Perform rolling reboot of **DC2** Servers (as described in *Rolling Reboot Procedure* above).

 9. Ensure no errors/warnings from Consul API in regard to ACL replication by running from any **DC2** Server:
   
   ```zsh
   curl "http://localhost:8500/v1/acl/replication?pretty"
   ```


### Configure Mesh GW ACL Tokens

 *Note: This should be run from any server in **DC1**.*

 1. If necessary, establish Consul environmental variables for variables outlined
 in section titled *Consul Environmental Variables*.

 2. Create Mesh GW Token policy by running:

   ```zsh
   mesh_gw_policy="mesh-gateway-policy.hcl"
   mesh_gw_rules=$( cat-CONFIG
   service_prefix "mesh-gateway" {
      policy = "write"
   }
   service_prefix "" {
      policy = "read"
   }
   node_prefix "" {
      policy = "read"
   }
   agent_prefix "" {
      policy = "read"
   }
   CONFIG
   )
   sudo touch $mesh_gw_policy && sudo chmod 0755 $mesh_gw_policy
   echo -e "$mesh_gw_rules" | sudo tee $mesh_gw_policy
   consul acl policy create -name mesh-gateway -rules @$mesh_gw_policy
   ```

 3. Create **DC1** Mesh GW Token by running:

   ```zsh
   consul acl token create -description "mesh-gateway primary datacenter token" -policy-name mesh-gateway
   ```

 4. Create **DC2** Mesh GW Token by running:

   ```zsh
   consul acl token create -description "mesh-gateway secondary datacenter token" -policy-name mesh-gateway
   ```

 5. Take note of **DC1** and **DC2** Mesh GW Token *SecretIDs*.
 

### Enable WAN Federation in DC1/DC2

1. Ensure all **DC1** servers have the following Connect stanza entry:

 ```zsh
 connect {
   enabled = true
   enable_mesh_gateway_wan_federation = true
 }
 ```

2. Perform rolling reboot of **DC1** Servers (as described in *Rolling Reboot Procedure* above).

3. Repeat steps 1 and 2 for **DC2** to ensure the following Connect stanza entry is set for all **DC2** servers:

 ```zsh
 primary_gateways = [ "consul-dc1-mesh-gw:8443"]
 connect {
   enabled = true
   enable_mesh_gateway_wan_federation = true
 }
 ```

### (Optional) Prepare Mesh GW Envoy log monitoring

*Note: For learning or troubleshooting purposes it may be beneficial to monitor the Envoy proxy log output after establishing the Mesh Gateway service within Consul. the steps outlined here establish a tail monitor for the Mesh GW servers prior to starting the associate Envoy Proxy.*

1. Establish secondary terminal for *consul-dc1-mesh-gw* and *consul-dc2-mesh-gw* servers.

2. From *consul-dc1-mesh-gw* run the following to setup Envoy Proxy log monitoring to stdout:

   ```zsh
   touch envoy.out && sudo chmod 777 envoy.out
   tail -f envoy.out
   ```

4. Repeat step 2 for *consul-dc2-mesh-gw*.



### Register Primary/Secondary DC Envoy Mesh Gateways

 1. If necessary, establish Consul environmental variables for variables outlined  in section titled *Consul Environmental Variables*.

 2. From *consul-dc1-mesh-gw*, run the following to establish DC1's primary  Mesh Gateway service:

 ```ruby
 consul connect envoy -gateway=mesh \ 
   -expose-servers -register \
   -service "mesh-gateway-dc1" \
   -address="20.0.0.55:8443" \
   -wan-address="192.169.7.150:8443" \
   -token="<primary_mesh_gw_token_secretID>" \
   -ca-file="/etc/consul.d/tls/consul-agent-ca.pem" \
   -client-cert="/etc/consul.d/tls/dc1-server-consul-0.pem" \
   -client-key="/etc/consul.d/tls/dc1-server-consul-0-key.pem" \
   -grpc-addr="https://127.0.0.1:8502" \
   -admin-bind="0.0.0.0:19000" \
   -tls-server-name="consul-dc1-server-0" \
   -bind-address="mesh-gateway-dc1=0.0.0.0:8443" -- -l trace &> envoy.out
 ```

 3. Repeat steps 1 and 2 for *consul-dc2-mesh-gw* with the following:

   ```ruby
   consul connect envoy -gateway=mesh \ 
     -expose-servers -register \
     -service "mesh-gateway-dc1" \
     -address="30.0.0.55:8443" \
     -wan-address="192.169.7.250:8443" \
     -token="<secondary_mesh_gw_token_secretID>" \
     -ca-file="/etc/consul.d/tls/consul-agent-ca.pem" \
     -client-cert="/etc/consul.d/tls/dc1-server-consul-0.pem" \
     -client-key="/etc/consul.d/tls/dc1-server-consul-0-key.pem" \
     -grpc-addr="https://127.0.0.1:8502" \
     -admin-bind="0.0.0.0:19000" \
     -tls-server-name="consul-dc1-server-0" \
     -bind-address="mesh-gateway-dc1=0.0.0.0:8443" -- -l trace &> envoy.out
   ```

### Verify Primary/Secondary DC Envoy Mesh GW Health

1. To verify health of the Envoy Mesh GW from the UI visit <a href="http://127.0.0.1:8500/ui">http://127.0.0.1:8500/ui and locate the *mesh-gateway-dc1* service to ensure its health checks are passing.

2. To verify health of Envoy Mesh GW from Consul CLI, run the following (*ensure &lt;dc&gt; is replaced with appropriate datacenter id*):

    ```zsh
   curl "http://127.0.0.1:8500/v1/health/checks/mesh-gateway-<dc>?pretty"
   ```

3. Perform step 1 or step 2 as desired for DC2's secondary Mesh GW.


### Test Mesh GW functionality by performing KV PUT Operation

1. From any **DC2** Server run:

   ```zsh
   consul kv put -datacenter=dc1 -token="<initial_mgmt_token>" \
     -ca-file="/etc/consul.d/tls/consul-agent-ca.pem" \
     -client-cert="/etc/consul.d/tls/dc2-server-consul-0.pem" \
     -client-key="/etc/consul.d/tls/dc2-server-consul-0-key.pem"
     from DCtwo
   ```

2. From any **DC1** Server run:

   ```zsh
   consul kv put -datacenter=dc2 -token="<initial_mgmt_token>" \
     -ca-file="/etc/consul.d/tls/consul-agent-ca.pem" \
     -client-cert="/etc/consul.d/tls/dc1-server-consul-0.pem" \
     -client-key="/etc/consul.d/tls/dc1-server-consul-0-key.pem"
     from DCone
   ```

3. If steps 1 and 2 are completed with no error, **WAN Federation via Mesh Gateways**
 has been established and continued testing can be accomplished as desired.


## Vagrant Cluster Removal

1. Destroy all Vagrant VirtualBox VMs

   ```zsh
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