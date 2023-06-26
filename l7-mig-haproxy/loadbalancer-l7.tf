# ------------------------------------------------------------------------------
# CREATE FORWARDING RULE
# ------------------------------------------------------------------------------

/********************* HAProxy instance configures L7 LB

resource "google_compute_global_forwarding_rule" "neo4j-lb7-forwarding-rule" {
  provider              = google-beta
  project               = var.project
  # If you change the name, also change in the main.tf startup script
  name                  = "neo4j-lb7-forwarding-rule-${var.env}"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80-80"
  target                = google_compute_target_http_proxy.neo4j-lb7-http-proxy.id

  labels = {
    "env"   = var.env
    "group" = var.labels_group
  }
}

resource "google_compute_url_map" "neo4j-lb7-url-map" {
  name            = "neo4j-lb7-url-map-${var.env}"
  default_service = google_compute_backend_service.neo4j-lb7-backend-service.id
}

resource "google_compute_target_http_proxy" "neo4j-lb7-http-proxy" {
  name    = "http-lb7-http-proxy-${var.env}"
  url_map = google_compute_url_map.neo4j-lb7-url-map.id
}

**************************/

# Backend service for MIG
resource "google_compute_backend_service" "neo4j-lb7-backend-service" {
  name                  = "neo4j-lb7-backend-service-${var.env}"
  provider              = google-beta
  port_name             = "http"
  protocol              = "HTTP"
  session_affinity      = "NONE"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_health_check.neo4j-lb7-hc.id]
  timeout_sec           = 30

  backend {
    group           = google_compute_instance_group_manager.neo4j-lb7-mig.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

# MIG for Internal TCP/UDP Load Balancer
resource "google_compute_instance_group_manager" "neo4j-lb7-mig" {
  name                  = "neo4j-lb7-mig-${var.env}"
  base_instance_name    = "neo4j-lb7-node-${var.env}"
  description           = "MIG for Neo4j nodes"
  zone                  = var.zone
  target_size           = var.nodeCount

  named_port {
    name = "http"
    port = 7474
  }
  named_port {
    name = "bolt"
    port = 7687
  }
  named_port {
    name = "http"
    port = 80
  }
  version {
    name              = "primary-neo4j-node-${var.env}"
    instance_template = google_compute_instance_template.neo4j-node-instance-template.id
  }

  stateful_disk {
    device_name = google_compute_instance_template.neo4j-node-instance-template.disk[1].device_name
    delete_rule = "ON_PERMANENT_INSTANCE_DELETION"
  }
}

# Health check for MIG
resource "google_compute_health_check" "neo4j-lb7-hc" {
  name                = "neo4j-lb7-hc-${var.env}"
  check_interval_sec  = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
  timeout_sec         = 5

  http_health_check {
    port                = 80
    port_specification  = "USE_FIXED_PORT"
    proxy_header        = "NONE"
    request_path        = "/"
  }
}