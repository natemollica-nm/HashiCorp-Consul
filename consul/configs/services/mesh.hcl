kind = "connect-proxy"
Name = "dc1-mesh-gateway"
port = 8443
proxy = {
  mesh_gateway              = {
    Mode = "local"
  }
  expose                    = {
    checks = true
  }
  destination_service_id    = "dc2-mesh-gateway"
  destination_service_name  = "dc2-mesh-gateway"
  local_service_address     = "20.0.0.30"
  local_service_port        = 8443
  local_service_socket_path = "/opt/consul/sockets/https/mesh.sock"
  upstreams                 = [
    {
      datacenter             = "dc1"
      local_bind_address     = "127.0.2.1"
      local_bind_socket_path = "/opt/consul/sockets/https/mesh.sock"
    }]
}