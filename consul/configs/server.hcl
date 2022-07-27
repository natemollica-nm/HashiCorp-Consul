data_dir           = "/opt/consul/data"
log_level          = "DEBUG"
server             = true

primary_datacenter = "dc1"

client_addr        = "0.0.0.0" # Sets interface for DNS, HTTP, HTTPS, GRPC / overridden by addresses entry / defaults to 127.0.0.1
bind_addr          = "0.0.0.0" # RPC internal cluster comms / defaults to 0.0.0.0 / sets advertise_addr (default)
advertise_addr     = "{{ GetInterfaceIP `eth1` }}" # Advertises IP to other nodes in cluster (set in case bind_addr not routable)
advertise_addr_wan = "{{ GetInterfaceIP `eth2` }}" # WAN Join advertisement for nodes

translate_wan_addrs = true
leave_on_terminate  = true

# Addresses default to client_addr
addresses {
  grpc  = "0.0.0.0"
  http  = "0.0.0.0"
  https = "0.0.0.0"
  dns   = "0.0.0.0"
}

ports {
  serf_lan          = 8301
  serf_wan          = 8302
  server            = 8300
  http              = 8500
  https             = 8501
  grpc              = 8502
  dns               = 8600
  sidecar_min_port  = 21000
  sidecar_max_port  = 21255
  expose_min_port   = 21500
  expose_max_port   = 21755
}

license_path = "/vagrant/consul/enterprise-license/consul.hclic"

enable_central_service_config = true

config_entries {
  bootstrap = [
    {
      Kind = "proxy-defaults"
      Name = "global"
      Config = {
        local_connect_timeout_ms = 1000
        handshake_timeout_ms = 10000
      }
      MeshGateway = {
        Mode = "local"
      }
      Expose = {
        Checks = true
      }
    }
  ]
}