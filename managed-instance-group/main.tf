# Setup Instance Template for Neo4j Nodes
resource "google_compute_instance_template" "neo4j-node-instance-template" {
  name         = "${var.vm_name}-${var.env}"
  project      = var.project
  provider     = google-beta
  #zone         = var.zone
  machine_type = var.machine_type
  tags = var.firewall_target_tags

  labels = {
    "env"   = var.env,
    "group" = var.labels_group
  }
  network_interface {
    network    = google_compute_network.neo4j-network.id
    subnetwork = google_compute_subnetwork.neo4j-subnetwork.id
  }
  # Boot Disk
  disk {
    source_image = var.vm_os_image
    boot         = true
    disk_type    = var.neo4j_disk_type
    disk_size_gb = 20
    auto_delete  = var.vm_boot_disk_delete_on_termination

    labels = {
      # Used by startup script to find other cluster members
      "env"   = var.env,
      "group" = var.labels_group
    }
  }

  # Attached disk
  disk {
    device_name   = "sbd"
    auto_delete   = var.vm_boot_disk_delete_on_termination
    boot          = false
    disk_type     = var.neo4j_disk_type
    disk_size_gb  = var.neo4j_disk_size
    mode          = "READ_WRITE"
    #type          = "SCRATCH" 
    type          = "PERSISTENT" 
  }

  # Update this as necessary to match your project and 
  # make sure update the `variables.tf` file to reflect 
  # your changes here.

  metadata_startup_script = templatefile("./scripts/core-5.sh", {
      #"forwarding-rule-name"       = google_compute_forwarding_rule.neo4j-forwarding-rule.name
      "forwarding_rule_name"       = "neo4j-forwarding-rule-${var.env}"
      "env"                        = var.env
      "region"                     = var.region
      "zone"                       = var.zone
      "adminPassword"              = var.adminPassword
      "nodeCount"                  = var.nodeCount
      "gdsNodeCount"               = var.gdsNodeCount
      "installGraphDataScience"    = "No"
      "graphDataScienceLicenseKey" = ""
      "installBloom"               = var.installBloom
      "bloomLicenseKey"            = var.bloomLicenseKey
    })

  service_account {
    scopes = ["cloud-platform"]
  }

  scheduling {
    preemptible       = var.scheduling_preemptible
    automatic_restart = var.scheduling_automatic_restart
  }

  lifecycle {
    create_before_destroy = true
  }
}