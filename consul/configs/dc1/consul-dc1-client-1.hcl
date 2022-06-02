node_name  = "consul-dc1-client-1"
datacenter = "dc1"
log_level  = "INFO"
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
  "consul-dc1-server-0",
  "consul-dc1-server-1",
  "consul-dc1-server-2",
  "consul-dc1-server-3"
]
license_path = "/etc/consul.d/consul.hclic"
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
