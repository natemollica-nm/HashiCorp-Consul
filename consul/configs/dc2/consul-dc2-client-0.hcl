node_name  = "consul-dc2-client-0"
datacenter = "dc2"
log_level  = "DEBUG"
server     = false

ui_config {
  enabled = true
}

domain     = "consul"
data_dir   = "/opt/consul/data"

client_addr    = "0.0.0.0" # Sets interface for DNS, HTTP, HTTPS, GRPC / overridden by addresses entry / defaults to 127.0.0.1
bind_addr      =  "0.0.0.0" # RPC internal cluster comms / defaults to 0.0.0.0 / sets advertise_addr (default)
advertise_addr = "{{ GetInterfaceIP `eth1` }}" # Advertises IP to other nodes in cluster (set in case bind_addr not routable)
advertise_addr_ipv4 = "{{ GetInterfaceIP `eth1` }}" # added for dual stack ipv4/ipv6 environments
advertise_addr_wan =  "{{ GetInterfaceIP `eth2` }}" # WAN Join advertisement for nodes
advertise_addr_wan_ipv4  = "{{ GetInterfaceIP `eth2` }}" # WAN Join - added for dual stack ipv4/ipv6 environments

retry_join         = [
  "consul-dc2-server-0",
  "consul-dc2-server-1",
  "consul-dc2-server-2",
  "consul-dc2-server-3",
  "consul-dc1-mesh-gw"
]

addresses {
  grpc = "127.0.2.1"
}

ports {             # https://www.consul.io/docs/agent/options#ports
  serf_lan  = 8301  # Default port for the default network segment
  serf_wan  = 8302
  server    = 8300  # Server RPC
  http      = 8500  # Recommended to remove HTTP for production environments.
  https     = 8501
  grpc      = 8502  # Not used on Server Agents. Only for Envoy -> Consul client agent gRPC
  dns       = 8600
  sidecar_min_port  = 21000
  sidecar_max_port  = 21255
  expose_min_port   = 21500
  expose_max_port   = 21755
}

license_path = "/etc/consul.d/consul.hclic"
primary_datacenter = "dc1"
connect {
  enabled = true
}
enable_central_service_config = true
