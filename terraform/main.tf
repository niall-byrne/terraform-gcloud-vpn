provider "google" {
  region      = "${var.region}"
  project     = "${var.project_id}"
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

  disk {
    image = "ubuntu-os-cloud/ubuntu-1604-xenial-v20170516"
    auto_delete = true
    size = 10
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

  provisioner "file" {
    source      = "${var.install_script_src_path}"
    destination = "${var.install_script_dest_path}"

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