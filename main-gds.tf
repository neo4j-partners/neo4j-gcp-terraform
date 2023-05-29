/*
Setup VM | Public IP | Storage Disk
*/
resource "google_compute_instance" "neo4j-gds-gce" {
  count        = var.gdsNodeCount
  name         = "${var.vm_name}-gds-${var.env}-${count.index + 1}"
  zone         = var.zone
  machine_type = var.gds_machine_type
  tags         = var.firewall_target_tags

  labels = {
    "env"   = var.env,
    "group" = var.labels_group
  }
  network_interface {
    network    = google_compute_network.neo4j-network.id
    subnetwork = google_compute_subnetwork.neo4j-subnetwork.id

    access_config {
    }
  }
  boot_disk {
    initialize_params {
      image = var.vm_os_image
      size  = var.neo4j_disk_size
      type  = var.neo4j_disk_type

      labels = {
        "env"   = var.env,
        "group" = var.labels_group
      }
    }
    auto_delete = var.vm_boot_disk_delete_on_termination
  }

  # Update this as necessary to match your project and 
  # make sure update the `variables.tf` file to reflect 
  # your changes here.

  allow_stopping_for_update = var.allow_stopping_for_update
  scheduling {
    preemptible       = var.scheduling_preemptible
    automatic_restart = var.scheduling_automatic_restart
  }
  lifecycle {
    ignore_changes = [attached_disk]
  }

  /*
  provisioner "file" {
    source      = "./scripts/core-5.sh"
    destination = "/tmp/core-5.sh"
  }
  */

  metadata_startup_script = templatefile("./scripts/core-5.sh", {
      "forwarding_rule_name"       = google_compute_forwarding_rule.neo4j-node-forwarding-rule.name
      "env"                        = var.env
      "region"                     = var.region
      "adminPassword"              = var.adminPassword
      "nodeCount"                  = var.nodeCount
      "gdsNodeCount"               = var.gdsNodeCount
      "installGraphDataScience"    = "Yes"
      "graphDataScienceLicenseKey" = var.graphDataScienceLicenseKey
      "installBloom"               = var.installBloom
      "bloomLicenseKey"            = var.bloomLicenseKey
    })

  service_account {
    scopes = ["cloud-platform"]
  }
}

/* 
This block will support the creation of the storage disk for the Neo4j Datastore.
Note: If disk is resized need to execute the following command 
inside the VM manually `sudo resize2fs </dev/sda>` 
*/
resource "google_compute_disk" "gds-disks" {
  count = var.gdsNodeCount
  name  = "neo4j-disk-${var.env}-gds-${count.index + 1}"
  size  = var.neo4j_disk_size
  type  = var.neo4j_disk_type
  zone  = var.zone
  labels = {
    "env" = var.env
  }
}

/*
Attach the disk created above to this VM
*/
resource "google_compute_attached_disk" "attach-gds-disk" {
  count    = var.gdsNodeCount
  disk     = google_compute_disk.gds-disks[count.index].id
  instance = google_compute_instance.neo4j-gds-gce[count.index].id
}