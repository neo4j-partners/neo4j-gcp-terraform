output "ssh_commands" {
  value = [
    for key, value in google_compute_instance.neo4j-gce[*].name : "gcloud compute ssh --zone '${var.zone}' '${value}' --project '${var.project}'"
  ]
}

output "neo4j_browser_url" {
  description = "Neo4j Browser URL"
  value = "http://${google_compute_forwarding_rule.http.ip_address}:7474"
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