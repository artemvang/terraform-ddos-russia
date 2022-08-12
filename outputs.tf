output "instances_ip" {
  value = [for i in hcloud_server.ddos_server : i.ipv4_address]
}
