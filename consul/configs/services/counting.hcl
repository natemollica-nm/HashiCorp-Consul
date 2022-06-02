service {
  name = "counting"
  port = 9003
  connect {
    proxy {
      mesh_gateway = {
        mode = "local"
      }
    }
  }
  check {
    id       = "counting-check"
    http     = "http://localhost:9003/health"
    method   = "GET"
    interval = "1s"
    timeout  = "1s"
  }
}
