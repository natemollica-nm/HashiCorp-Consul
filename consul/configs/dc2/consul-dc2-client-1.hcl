node_name  = "consul-dc2-client-1"
datacenter = "dc2"
log_level  = "DEBUG"
server     = false
ui_config {
  enabled = true
}
domain     = "consul"
data_dir   = "/opt/consul/data"

advertise_addr = "{{ GetInterfaceIP `eth1` }}"
client_addr    = "0.0.0.0"
bind_addr      = "0.0.0.0"

leave_on_terminate = true
retry_join         = [
  "consul-dc2-server-0",
  "consul-dc2-server-1",
  "consul-dc2-server-2",
  "consul-dc2-server-3"
]
ports {
  http  = 8500
  https = 8501
  grpc  = 8502
}
license_path = "/etc/consul.d/consul.hclic"
primary_datacenter = "dc1"
connect {
  enabled = true
}
enable_central_service_config = true

