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
      "forwarding_rule_name"       = "neo4j-gds-node-forwarding-rule-${var.env}-1"
      "env"                        = var.env
      "region"                     = var.region
      "zone"                       = var.zone
      "adminPassword"              = var.adminPassword
      "nodeCount"                  = 3
      "gdsNodeCount"               = 1
      "installGraphDataScience"    = "Yes"
      "graphDataScienceLicenseKey" = "eyJhbGciOiJQUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6Imx1a2UuZ2Fubm9uQG5lb3RlY2hub2xvZ3kuY29tIiwiZXhwIjoxNzA2NjU5MjAwLCJmZWF0dXJlVmVyc2lvbiI6IioiLCJvcmciOiJQU0EgUmVzb3VyY2VzIC0gRE8gTk9UIFVTRSIsInB1YiI6Im5lbzRqLmNvbSIsInF1YW50aXR5IjoiMSIsInJlZyI6Ikx1a2UgR2Fubm9uIiwic2NvcGUiOiJQcm9kdWN0aW9uIiwic3ViIjoibmVvNGotZ2RzIiwidmVyIjoiKiIsImlzcyI6Im5lbzRqLmNvbSIsIm5iZiI6MTY3MDYwMDMzNSwiaWF0IjoxNjcwNjAwMzM1LCJqdGkiOiIxZXh6NjN5bC0ifQ.T12mKUXOil9GXvmWFpmdEvfFfI8AbQqRItfOknjsEvcdqt2to42OdQsfL5ZUj5yhzFaEpKYpsv8Er7AmmirNlnVnx7Xv77_bRpsxS_W6XA_BZCbtNNtrJrp3av0blmhMabyWEJcIqijcX3o1wnIuoOZMjCWsSah0yl9VkqRlyCpgX7jtwvssGuvo7SoZxtIQ8FSpDFiNv-n8jxh59vz68e-5GgfxkvyPyAIYz6uluugXKbrjl-HA2y9jCRefZAB4EEiFLg-w4tveEG2pUYtU7FyoZqddnwUSjIJE4Um9xEPlZBD8v8ymFwf5VISjusklG-sJroORZXfz7h1xC4QeFQ"
      "installBloom"               = "Yes"
      "bloomLicenseKey"            = "eyJhbGciOiJQUzI1NiIsInR5cCI6IkpXVCJ9.eyJhbm4iOiIiLCJlbWFpbCI6ImxpY2Vuc2luZ0BuZW80ai5jb20iLCJleHAiOjE3MTk3MjAwMDAsIm9yZyI6Ik5lbzRqIiwicHViIjoiTmVvNGogSW5jIiwicmVnIjoiTmVvNGogRW1wbG95ZWUiLCJzY29wZSI6IkludGVybmFsIFVzZSIsInNvdXJjZV9pZHMiOiIiLCJzdWIiOiJuZW80ai1ibG9vbS1zZXJ2ZXIiLCJ2ZXIiOiIqIiwiaXNzIjoibmVvNGouY29tIiwibmJmIjoxNjgyNjEwMTEyLCJpYXQiOjE2ODI2MTAxMTIsImp0aSI6IklNY1FLRDk3NCJ9.l3VlA5qrfECxVl2FolU7qEG0fCkVvqMXBrKctBXtXMUmb6RCbzFOHxLMF8mXNwa739dVMDxf_Mg-2ziXQPwA-k4jU_1gx3TXElQrr_4MsT7af3ocvQeGdxCM_AT8zLV6wLliatlkcimKBdvgi6HL7eApjtfMPXlBi4tTPPqZeao6WGnP1Pe5Bx3IIEUI9KBLsLfhlHqwVky_wp2cRE2w6sho7YixN5lOnh-v3rfiM0O2The_sr5pKc0D8LykCBBoR2m7yUj33c0NlggwtPVGRDVGGHeJWLBK5b0gssYCoIVroQ5UmZ2Tvy-O86gz9TZu4FykP-wYecZTW4b5xSlXYw"
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