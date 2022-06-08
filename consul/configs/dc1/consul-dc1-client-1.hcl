node_name  = "consul-dc1-client-1"
datacenter = "dc1"
log_level  = "INFO"
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

leave_on_terminate = true
retry_join         = [
  "consul-dc1-server-0",
  "consul-dc1-server-1",
  "consul-dc1-server-2",
  "consul-dc1-server-3",
  "consul-dc1-mesh-gw"
]
license_path = "/etc/consul.d/consul.hclic"

addresses {
  grpc = "127.0.2.1"
}
ports {
  http  = 8500
  https = 8501
  grpc  = 8502
}
primary_datacenter = "dc1"
connect {
  enabled = true
}
enable_central_service_config = true
