provider "google" {
  region      = "${var.region}"
  project     = "${var.project_id}"
  version     = "2.12.0"
}

resource "google_compute_address" "vpn-address" {
  project     = "${var.project_id}"
  region      = "${var.region}"
  name        = "server-address"
}

resource "google_compute_instance" "vpn-server" {
  project         = "${var.project_id}"
  zone            = "${var.zone}"

  count           = 1
  name            = "vpn-server-${count.index}"
  machine_type    = "f1-micro"
  tags            = ["vpn-server"]
  can_ip_forward  = true

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1604-xenial-v20170516"
      size = 10
    }
    auto_delete = true
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = "${google_compute_address.vpn-address.address}"
    }
  }

  metadata {
    ssh-keys = "root:${file("${var.public_key_path}")}"
  }

  provisioner "local-exec" {
    command     = "cd ansible && ./playbook.sh ${var.private_key_path} ${google_compute_address.vpn-address.address}"
    on_failure  = "fail"

    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.private_key_path}")}"
      agent       = false
    }
  }

}

resource "google_compute_firewall" "default" {
  name    = "vpn-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["vpn-server"]
}

output "ip" {
  value = "${google_compute_address.vpn-address.address}"
}
