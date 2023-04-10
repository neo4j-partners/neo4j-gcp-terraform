/*
Setup VPC
*/
resource google_compute_network vpc-custom {
  name = "${var.vpc_name}-${var.env}"
  # This is set to false to avoid default subnetwork creation
  auto_create_subnetworks = var.auto_create_subnetworks
}

/*
Create Subnet
*/
resource "google_compute_subnetwork" "sub-custom" {
  name = "subnetwork-neo4j-${var.env}"
  network = google_compute_network.vpc-custom.id
  ip_cidr_range = var.subnetwork_range
  region = var.region
  private_ip_google_access = "true"
}

/*
Setup Firewall
*/
resource "google_compute_firewall" "neo4j-access-internal" {
  name    = "neo4j-cluster-access-internal-${var.env}"
  network = google_compute_network.vpc-custom.id

  allow {
    protocol = "tcp"
    ports    = var.neo4j_access_internal_ports
  }
  allow {
    protocol = "udp"
    ports    = var.neo4j_access_internal_ports
  }

  target_tags   = var.firewall_target_tags
  source_ranges = [var.subnetwork_range]
#  source_ranges = ["0.0.0.0/0"]
  priority      = 1000
}

resource "google_compute_firewall" "neo4j-access-external" {
  name    = "neo4j-cluster-access-external-${var.env}"
  network = google_compute_network.vpc-custom.id

  allow {
    protocol = "tcp"
    ports    = var.neo4j_access_external_ports
  }

  target_tags   = var.firewall_target_tags
  priority      = 1000
}

/*
Setup DNS
resource "google_dns_managed_zone" "cluster-private-zone" {
  name        = "${var.env}-private-zone"
  dns_name    = var.private_zone_dns

  labels = {
    "env"   = var.env
    "group" = var.labels_group
  }

  visibility = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.vpc-custom.id
    }
  }
}

resource "google_dns_record_set" "recordset" {
  # provider = "google-beta"
  managed_zone = google_dns_managed_zone.cluster-private-zone.name
  name         = var.recordset_name
  rrdatas      = [google_compute_forwarding_rule.neo4j-forwardingrule.ip_address]
  # Type and TTL are hard set 
  type = "A"
  ttl  = 86400
}
*/