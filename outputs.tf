output "ssh_commands" {
  value = [
    for key, value in google_compute_instance.neo4j-gce[*].name : "gcloud compute ssh --zone '${var.zone}' '${value}' --project '${var.project}'"
  ]
}

output "neo4j_browser_url" {
  description = "Neo4j Browser URL"
  value = "http://${google_compute_forwarding_rule.http.ip_address}:7474"
  depends_on = [
    google_compute_forwarding_rule.http,
    google_compute_instance.neo4j-gce,
  ]
}

output "neo4j_bloom_url" {
  description = "Neo4j Bloom URL"
  value = "http://${google_compute_forwarding_rule.http.ip_address}:7474/bloom"
}

output "neo4j_bolt_url" {
  description = "Neo4j Bolt URL"
  value = "bolt://${google_compute_forwarding_rule.http.ip_address}:7687"
}

output "neo4j_password" {
  description = "Neo4j admin password"
  value = var.adminPassword
}

output "node_count" {
  value = var.nodeCount
}

output "gds_installed" {
  description = "Install GDS"
  value = var.installGraphDataScience
}

output "bloom_installed" {
  description = "Install Bloom"
  value = var.installBloom
}