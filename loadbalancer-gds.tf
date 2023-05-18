# ------------------------------------------------------------------------------
# CREATE FORWARDING RULE
# ------------------------------------------------------------------------------
resource "google_compute_forwarding_rule" "neo4j-gds-node-forwarding-rule" {
  count                 = var.gdsNodeCount
  provider              = google-beta
  project               = var.project
  # If you change the name, also change in the main.tf startup script
  name                  = "neo4j-gds-node-forwarding-rule-${var.env}-${count.index + 1}"
  region                = var.region
  target                = google_compute_target_pool.neo4j-gds-tp.self_link
  load_balancing_scheme = "EXTERNAL"
  all_ports             = true
  #ports                 = [7474, 7687]
  ip_protocol           = "TCP"

  labels = {
    "env"   = var.env
    "group" = var.labels_group
  }
}

# ------------------------------------------------------------------------------
# CREATE TARGET POOL
# ------------------------------------------------------------------------------
resource "google_compute_target_pool" "neo4j-gds-tp" {
  provider         = google-beta
  project          = var.project
  name             = "neo4j-gds-tp-${var.env}"
  region           = var.region
  session_affinity = "NONE"

  # Instances only include Secondary (GDS) nodes
  instances = google_compute_instance.neo4j-gds-gce.*.self_link
}