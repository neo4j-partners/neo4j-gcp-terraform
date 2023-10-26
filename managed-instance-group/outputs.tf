#output "ssh_commands" {
#  value = [
#    for key, value in google_compute_instance.neo4j-gce[*].name : "gcloud compute ssh --zone '${var.zone}' '${value}' --project '${var.project}'"
#  ]
#}

output "neo4j_browser_url" {
  description = "Neo4j Browser URL"
  value = "http://${google_compute_forwarding_rule.neo4j-forwarding-rule.ip_address}:7474"
  depends_on = [
    google_compute_forwarding_rule.neo4j-forwarding-rule
  ]
}

output "neo4j_bloom_url" {
  description = "Neo4j Bloom URL"
  value = "http://${google_compute_forwarding_rule.neo4j-forwarding-rule.ip_address}:7474/bloom"
  depends_on = [
    google_compute_forwarding_rule.neo4j-forwarding-rule
  ]
}

output "neo4j_bolt_url" {
  description = "Neo4j Bolt URL"
  value = "bolt://${google_compute_forwarding_rule.neo4j-forwarding-rule.ip_address}:7687"
}

#output "neo4j_gds_browser_url" {
# description = "Neo4j GDS Browser URL"
#  value = [
#    for key, value in google_compute_forwarding_rule.neo4j-gds-node-forwarding-rule[*].ip_address : "http://${value}:7474"
#  ]
#
#  depends_on = [
#    google_compute_forwarding_rule.neo4j-gds-node-forwarding-rule
#  ]
#}

#output "neo4j_gds_bloom_url" {
#  description = "Neo4j GDS Bloom URL"
#  value = [
#    for key, value in google_compute_forwarding_rule.neo4j-gds-node-forwarding-rule[*].ip_address : "http://${value}:7474/bloom"
#  ]
#}

output "neo4j_password" {
  description = "Neo4j admin password"
  value = var.adminPassword
}

output "node_count" {
  value = var.nodeCount
}

#output "gds_node_count" {
#  value = var.gdsNodeCount
#}

#output "bloom_installed" {
#  description = "Install Bloom"
#  value = var.installBloom
#}