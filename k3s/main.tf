terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.71.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)

  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_firewall" "k3s-firewall" {
  name    = "k3s-firewall"
  network = "default"
  source_ranges = [ "0.0.0.0/0" ]

  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }

  target_tags = ["k3s"]
}

resource "google_compute_instance" "k3s_master_instance" {
  name         = "k3s-master"
  machine_type = "e2-medium"
  tags         = ["k3s", "k3s-master"]

  boot_disk {
    initialize_params {
      image = "debian-9-stretch-v20200805"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  provisioner "local-exec" {
    command = <<EOT
            k3sup install \
            --ip ${self.network_interface[0].access_config[0].nat_ip} \
            --context k3s \
            --ssh-key ~/.ssh/google_compute_engine \
            --user $(whoami)
        EOT
  }

  depends_on = [
    google_compute_firewall.k3s-firewall,
  ]
}

resource "google_compute_instance" "k3s_worker_instance" {
  count        = 3
  name         = "k3s-worker-${count.index}"
  machine_type = "e2-medium"
  tags         = ["k3s", "k3s-worker"]

  boot_disk {
    initialize_params {
      image = "debian-9-stretch-v20200805"
    }
  }

  network_interface {
    network = "default"

    access_config {}
  }

  provisioner "local-exec" {
    command = <<EOT
            k3sup join \
            --ip ${self.network_interface[0].access_config[0].nat_ip} \
            --server-ip ${google_compute_instance.k3s_master_instance.network_interface[0].access_config[0].nat_ip} \
            --ssh-key ~/.ssh/google_compute_engine \
            --user $(whoami)
        EOT
  }

  depends_on = [
    google_compute_firewall.k3s-firewall,
  ]
}