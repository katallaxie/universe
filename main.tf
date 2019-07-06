provider "scaleway" {
  region = "${var.region}"
}

data "scaleway_image" "docker" {
  architecture = "${lookup(var.archs, var.type)}"
  name         = "Docker"
}

resource "scaleway_security_group" "worker" {
  name        = "Default Worker Security Group"
  description = "This is the security group for the worker"

  enable_default_security = true
  stateful                = true
  inbound_default_policy  = "drop"
  outbound_default_policy = "accept"
}

resource "scaleway_security_group_rule" "accept_tcp" {
  security_group = "${scaleway_security_group.worker.id}"

  action    = "accept"
  direction = "inbound"

  ip_range = "0.0.0.0/0"
  protocol = "TCP"
  port     = "${element(var.worker_tcp_ports, count.index)}"
  count    = "${length(var.worker_tcp_ports)}"
}

resource "scaleway_ip" "worker" {}

resource "scaleway_server" "worker" {
  name                = "worker"
  image               = "${data.scaleway_image.docker.id}"
  type                = "${var.type}"
  enable_ipv6         = "${var.enable_ipv6}"
  public_ip           = "${scaleway_ip.worker.ip}"

  tags = [
    "universe",
    "remote",
  ]

  connection {
    host        = "${scaleway_ip.worker.ip}"
    type        = "ssh"
    user        = "root"
  }

  security_group = "${scaleway_security_group.worker.id}"

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://raw.githubusercontent.com/katallaxie/universe/master/bootstrap.sh | sudo bash -s -- yes yes yes ${var.acme_domain} ${var.acme_email}"
    ]
  }
}
