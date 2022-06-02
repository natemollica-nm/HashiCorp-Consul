node_name  = "consul-dc2-server-0"
datacenter = "dc2"
log_level  = "DEBUG"
server     = true
ui_config {
  enabled = true
}
domain     = "consul"
data_dir   = "/opt/consul/data"

advertise_addr = "{{ GetInterfaceIP `eth1` }}"
client_addr    = "0.0.0.0"
bind_addr      = "0.0.0.0"
advertise_addr_wan  = "{{ GetInterfaceIP `eth2` }}"
translate_wan_addrs = true

leave_on_terminate = true

retry_join         = [
  "consul-dc2-server-0",
  "consul-dc2-server-1",
  "consul-dc2-server-2",
  "consul-dc2-server-3"
]
addresses {
  grpc  = "127.0.2.1"
}
ports {
  serf_lan  = 8301
  serf_wan  = 8302
  server    = 8300
  http      = 8500
  https     = 8501
  grpc      = 8502
  dns       = 8600
  sidecar_min_port  = 21000
  sidecar_max_port  = 21255
  expose_min_port   = 21500
  expose_max_port   = 21755
}

bootstrap_expect = 5
license_path = "/etc/consul.d/consul.hclic"

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
    }
  ]
}