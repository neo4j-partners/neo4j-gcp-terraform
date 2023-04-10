/*
output "ssh_commands" {
  value = [
    for key, value in google_compute_instance.neo4j-gce[*].public_ip : "ssh -o StrictHostKeyChecking=no -i ${var.private_key_path} ec2-user@${value}"
  ]
}
*/

output "neo4j_browser_url" {
  description = "Neo4j Browser URL"
  value = "http://${google_compute_forwarding_rule.neo4j-forwardingrule.ip_address}:7474"
}

output "neo4j_password" {
  description = "Neo4j admin password"
  value = var.adminPassword
}

output "node_count" {
  value = var.nodeCount
}