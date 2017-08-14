# -------- Base Cluster Confiruation -------- #

region = "us/east"

data_dir = "/var/lib/nomad"

bind_addr = "127.0.0.1"

log_level = "DEBUG"

enable_debug = true

addresses {
  http = "172.17.8.101"
  rpc = "172.17.8.101"
  serf = "172.17.8.101"
}

advertise {
  http = "172.17.8.101:4646"
  rpc = "172.17.8.101:4647"
  serf = "172.17.8.101:4648"
}

consul {
  address = "127.0.0.1:8500"
  server_service_name = "nomad-server"
  client_service_name = "nomad-client"

  auto_advertise = true

  server_auto_join = true
  client_auto_join = true
}
