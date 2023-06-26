resource "google_compute_instance" "neo4j-haproxy" {
  name         = "neo4j-haproxy-${var.env}"
  machine_type = "e2-small"
  #zone = "us-east4-c"
  #can_ip_forward      = false
  #deletion_protection = false
  #enable_display      = false
  tags = var.firewall_target_tags

  network_interface {
    #network    = "default"
    network    = google_compute_network.neo4j-network.id
    subnetwork = google_compute_subnetwork.neo4j-subnetwork.id
    access_config {
      // Ephemeral IP
    }
  }
  boot_disk {
    auto_delete = true
    device_name = "neo4j-haproxy-jsh"

    initialize_params {
      image = "projects/rhel-cloud/global/images/rhel-9-v20221206"
      size  = 20
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  #metadata_startup_script = "yum -y install haproxy telnet wget"
  metadata_startup_script = templatefile("./scripts/configure_haproxy.sh", {
      "env"                        = var.env
      "region"                     = var.region
      "zone"                       = var.zone
  })


  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
