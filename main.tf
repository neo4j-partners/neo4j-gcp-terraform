/*
Setup VM | Public IP | Storage Disk
*/
locals {
  # Will be removed in future commits
  discovery_addresses = join(",", [for num in range(var.nodeCount) : format("%s%s", "http-forwardingrule-${var.env}-${num + 1}", ":5000")])
}

resource "google_compute_instance" "neo4j-gce" {
  count        = var.nodeCount
  name         = "${var.vm_name}-${var.env}-${count.index + 1}"
  zone         = var.zone
  machine_type = var.machine_type
  tags         = var.firewall_target_tags

  labels = {
    "env"   = var.env,
    "group" = var.labels_group
  }
  network_interface {
#    network = "default"
    network    = google_compute_network.vpc-custom.id
    subnetwork = google_compute_subnetwork.sub-custom.id

    # Assign public ip
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

  metadata_startup_script = templatefile("./scripts/core-5.sh", {
      "deployment"                 = var.env
      "region"                     = var.region
      "graphDatabaseVersion"       = var.neo4j_version
      "adminPassword"              = var.adminPassword
      "nodeCount"                  = var.nodeCount
      "installGraphDataScience"    = var.installGraphDataScience
      "graphDataScienceLicenseKey" = var.graphDataScienceLicenseKey
      "installBloom"               = var.installBloom
      "bloomLicenseKey"            = var.bloomLicenseKey
    })

  service_account {
    scopes = ["cloud-platform"]
  }
  depends_on = [local_file.render_setup_template]
}

/*
Setup template renderer for validation of VM setup script
*/
resource "local_file" "render_setup_template" {
  count    = var.nodeCount
  filename = "./out/rendered_template_${count.index + 1}.sh"
  content = templatefile("./scripts/core-5.sh", {
      "deployment"                 = var.env
      "region"                     = var.region
      "graphDatabaseVersion"       = var.neo4j_version
      "adminPassword"              = var.adminPassword
      "nodeCount"                  = var.nodeCount
      "installGraphDataScience"    = var.installGraphDataScience
      "graphDataScienceLicenseKey" = var.graphDataScienceLicenseKey
      "installBloom"               = var.installBloom
      "bloomLicenseKey"            = var.bloomLicenseKey
  })
}

/* 
This block will support the creation of the storage disk for the Neo4j Datastore.
Note: If disk is resized need to execute the following command 
inside the VM manually `sudo resize2fs </dev/sda>` 
resource "google_compute_disk" "disks" {
  count = var.nodeCount
  name  = "neo4j-disk-${var.env}-${count.index + 1}"
  size  = var.neo4j_disk_size
  type  = var.neo4j_disk_type
  zone  = var.zone
  labels = {
    "env" = var.env
  }
}

Attach the disk created above to this VM
resource "google_compute_attached_disk" "attach-disks" {
  count    = var.nodeCount
  disk     = google_compute_disk.disks[count.index].id
  instance = google_compute_instance.neo4j-gce[count.index].id
}
*/