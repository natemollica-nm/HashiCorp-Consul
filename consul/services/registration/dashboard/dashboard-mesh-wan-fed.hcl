service {
  name = "dashboard"
  port = 9002

  connect {
    proxy {
      mesh_gateway {
        mode = "remote"
      }
      upstreams = [
        {
          destination_name = "counting"
          datacenter       = "dc1"
        }
      ]
    }
  }

  check {
    id       = "dashboard-check"
    http     = "http://localhost:9002/health"
    method   = "GET"
    interval = "1s"
    timeout  = "1s"
  }
}
