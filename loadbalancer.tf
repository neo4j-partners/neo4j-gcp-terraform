# ------------------------------------------------------------------------------
# CREATE FORWARDING RULE
# ------------------------------------------------------------------------------
resource "google_compute_forwarding_rule" "neo4j-forwardingrule" {
  provider              = google-beta
  project               = var.project
  name                  = "http-forwardingrule-${var.env}"
  region                = var.region
  # Only used for INTERNAL forwarding
  #network               = google_compute_network.vpc-custom.id
  target                = google_compute_target_pool.neo4j-tp.self_link
  load_balancing_scheme = "EXTERNAL"
#  port_range            = "0.0.0.0/0"
  ip_protocol           = "TCP"

  labels = {
    "env"   = var.env
    "group" = var.labels_group
  }
}

# ------------------------------------------------------------------------------
# CREATE TARGET POOL
# ------------------------------------------------------------------------------
resource "google_compute_target_pool" "neo4j-tp" {
  provider         = google-beta
  project          = var.project
  name             = "neo4j-tp-${var.env}"
  region           = var.region
  session_affinity = "NONE"

  instances = google_compute_instance.neo4j-gce.*.self_link

  health_checks = google_compute_http_health_check.neo4j-http-health-check.*.name
}

# ------------------------------------------------------------------------------
# CREATE HEALTH CHECK
# ------------------------------------------------------------------------------
resource "google_compute_http_health_check" "neo4j-http-health-check" {
  count = var.enable_health_check ? 1 : 0

  provider            = google-beta
  project             = var.project
  name                = "http-healthcheck-${var.env}"
#  request_path        = "/browser"
  request_path        = "/"
  port                = 7474
  check_interval_sec  = 30
  healthy_threshold   = 2
  unhealthy_threshold = 2
  timeout_sec         = 10
}

# ------------------------------------------------------------------------------
# CREATE FIREWALL FOR THE HEALTH CHECKS
# ------------------------------------------------------------------------------
# Health check firewall allows ingress tcp traffic from the health check IP addresses
resource "google_compute_firewall" "health_check" {
  count = var.enable_health_check ? 1 : 0

  provider = google-beta
  project  = var.project
  name     = "health-check-fw-${var.env}"
  network  = google_compute_network.vpc-custom.id

  allow {
    protocol = "tcp"
    ports    = [7474, 7687]
  }

  # These IP ranges are required for health checks
  source_ranges = ["209.85.152.0/22", "209.85.204.0/22", "35.191.0.0/16"]

  # Target tags define the instances to which the rule applies
  target_tags = var.firewall_target_tags
}