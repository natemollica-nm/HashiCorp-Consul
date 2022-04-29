node_name  = "consul-client-2"
datacenter = "dc1"
log_level  = "INFO"
server     = false
ui_config {
  enabled = true
}
domain     = "consul"
data_dir   = "/opt/consul/data"

advertise_addr = "192.168.56.71"
bind_addr      = "192.168.56.71"
client_addr    = "192.168.56.71"

leave_on_terminate = true
retry_join         = [
  "192.168.56.10",
  "192.168.56.20",
  "192.168.56.30",
  "192.168.56.40",
  "192.168.56.50",
  "192.168.56.60",
]
encrypt = "rO6s/hqA5we4zIShtha0yMHUjctsYLtnZZJy8XXF23E="
