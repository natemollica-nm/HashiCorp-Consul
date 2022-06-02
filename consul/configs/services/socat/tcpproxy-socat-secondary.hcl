service {
  name = "tcpproxy"
  port = 8443
  connect {
    sidecar_service {
      proxy {
        upstreams = [
          {
            destination_name = "socat"
            datacenter = "dc1"
            local_bind_port = 10000
          }
        ]
      }
    }
  }
}