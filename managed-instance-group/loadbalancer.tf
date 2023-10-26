# ------------------------------------------------------------------------------
# CREATE FORWARDING RULE
# ------------------------------------------------------------------------------

resource "google_compute_forwarding_rule" "neo4j-forwarding-rule" {
  provider              = google-beta
  project               = var.project
  region                = var.region
  # If you change the name, also change in the main.tf startup script
  name                  = "neo4j-forwarding-rule-${var.env}"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  all_ports             = true
  #ports                 = [7474, 7687]
  backend_service       = google_compute_region_backend_service.neo4j-backend-service.id

  labels = {
    "env"   = var.env
    "group" = var.labels_group
  }
}

# Backend service for MIG
resource "google_compute_region_backend_service" "neo4j-backend-service" {
  name                  = "neo4j-backend-service-${var.env}"
  provider              = google-beta
  region                = var.region
  #port_name             = "http"
  protocol              = "TCP"
  #session_affinity      = "NONE"
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_region_health_check.neo4j-hc.id]
  timeout_sec           = 30

  backend {
    group           = google_compute_region_instance_group_manager.neo4j-mig.instance_group
    balancing_mode  = "CONNECTION"
    #balancing_mode  = "UTILIZATION"
    #capacity_scaler = 1.0
  }
}

# MIG for External TCP/UDP Load Balancer
resource "google_compute_region_instance_group_manager" "neo4j-mig" {
  name                  = "neo4j-mig-${var.env}"
  base_instance_name    = "neo4j-node-${var.env}"
  description           = "MIG for Neo4j nodes"
  #zone                  = var.zone
  region                = var.region
  target_size           = var.nodeCount

  named_port {
    name = "http"
    port = 7474
  }
  named_port {
    name = "bolt"
    port = 7687
  }
  version {
    name              = "primary-neo4j-node-${var.env}"
    instance_template = google_compute_instance_template.neo4j-node-instance-template.id
  }

  stateful_disk {
    device_name = google_compute_instance_template.neo4j-node-instance-template.disk[1].device_name
    delete_rule = "ON_PERMANENT_INSTANCE_DELETION"
  }

  update_policy {
    type                           = "PROACTIVE"
    instance_redistribution_type   = "NONE"
    minimal_action                 = "RESTART"
    max_surge_percent              = 0
    max_unavailable_fixed          = 3
    replacement_method             = "RECREATE"
    }
}

# Health check for MIG
resource "google_compute_region_health_check" "neo4j-hc" {
  name                = "neo4j-hc-${var.env}"
  region              = var.region
  check_interval_sec  = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
  timeout_sec         = 5

  http_health_check {
    port                = 7474
    port_specification  = "USE_FIXED_PORT"
    proxy_header        = "NONE"
    request_path        = "/"
  }
}