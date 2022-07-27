service {
  name = "fake-service"
  port = 9090

  connect {
    sidecar_service {}
  }

  checks = [
    {
      id       = "fake-service-http-health"
      http     = "http://127.0.0.1:9090/health"
      method   = "GET"
      interval = "1s"
      timeout  = "1s"
    },
    {
      id       = "fake-service-http-ready"
      http     = "http://127.0.0.1:9090/ready"
      method   = "GET"
      interval = "5s"
      timeout  = "1s"
    },
  ]
}