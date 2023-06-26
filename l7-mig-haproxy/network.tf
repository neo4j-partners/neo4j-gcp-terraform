# Setup Neo4J VPC Network
resource google_compute_network neo4j-network {
  name = "${var.vpc_name}-${var.env}"
  # This is set to false to avoid default subnetwork creation
  auto_create_subnetworks = var.auto_create_subnetworks
}

# Setup Neo4J VPC Subnetwork
resource "google_compute_subnetwork" "neo4j-subnetwork" {
  name                     = "subnetwork-neo4j-${var.env}"
  network                  = google_compute_network.neo4j-network.id
  ip_cidr_range            = var.subnetwork_range
  region                   = var.region
  private_ip_google_access = "true"
}

# Neo4j Node/GDS Cloud NAT 
#--------------------------------------------------------------

# Cloud NAT used to allow egress traffic to internet for updates - no ingress
resource "google_compute_router" "neo4j-router" {
  name          = "neo4j-router-${var.env}"
  description   = "router used for neo4j-network Cloud NAT"
  region        = var.region
  network       = google_compute_network.neo4j-network.name
}

resource "google_compute_router_nat" "neo4j-cloud-nat" {
  name                                  = "neo4j-cloud-nat-${var.env}"
  router                                = google_compute_router.neo4j-router.name
  region                                = var.region
  nat_ip_allocate_option                = "AUTO_ONLY"
  #nat_ips                               = google_compute_address.neo4j-cloud-nat-external-ip.*.self_link
  source_subnetwork_ip_ranges_to_nat    = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  enable_endpoint_independent_mapping   = false
  min_ports_per_vm                      = 64

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_firewall" "neo4j-allow_egress" {
  name          = "neo4j-fw-allow-egress-${var.env}"
  network       = google_compute_network.neo4j-network.id
  target_tags   = var.firewall_target_tags
  #source_ranges = ["0.0.0.0/0"]
  source_ranges = [var.subnetwork_range]
  direction     = "EGRESS"
  #destination_ranges = [for subnet in var.subnets : subnet.collector_vpc_subnet_cidr if subnet.mirror_vpc_network == each.value]

  allow {
    protocol = "all"
  }
}

# Setup Firewall Rule to Allow Health Checks to be performed
resource "google_compute_firewall" "neo4j-fw-allow-hc" {
  name          = "neo4j-fw-allow-hc-${var.env}"
  direction     = "INGRESS"
  network       = google_compute_network.neo4j-network.id
  target_tags   = var.firewall_target_tags
  priority      = 1000
  source_ranges = ["35.191.0.0/16", "209.85.152.0/22", "209.85.204.0/22"]

  allow {
    protocol = "tcp"
    ports    = var.neo4j_access_external_ports
  }
}

# Setup Firewall Rule to Allow Traffic from vpn to backends
resource "google_compute_firewall" "neo4j-neo4j-fw-allow-external" {
  name          = "neo4j-fw-allow-external-${var.env}"
  direction     = "INGRESS"
  network       = google_compute_network.neo4j-network.id
  target_tags   = var.firewall_target_tags
  priority      = 1000
  #source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = var.neo4j_access_external_ports
  }
}

# Setup Firewall Rule to Allow Traffic from vpn to backends
resource "google_compute_firewall" "neo4j-fw-allow-internal" {
  name          = "neo4j-fw-allow-subnetwork-${var.env}"
  direction     = "INGRESS"
  network       = google_compute_network.neo4j-network.id
  target_tags   = var.firewall_target_tags
  priority      = 1000
  source_ranges = [var.subnetwork_range]

  allow {
    protocol = "tcp"
    ports    = var.neo4j_access_internal_ports
  }

  allow {
    protocol = "udp"
    ports    = var.neo4j_access_internal_ports
  }
}

# Setup SSH access for Neo4j Nodes
resource "google_compute_firewall" "neo4j-fw-allow-ssh" {
  name          = "neo4j-fw-allow-ssh-${var.env}"
  network       = google_compute_network.neo4j-network.id
  target_tags   = var.firewall_target_tags
  disabled      = false
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["35.235.240.0/20"]

  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
}