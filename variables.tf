variable "project" {
  description = "The project id where the VPC being provioned"
  type        = string
}

variable "service_account" {
  description = "Service account used by this Terraform deployment"
  type        = string
}

variable "region" {
  description = "Region where the VM is being provisioned"
  type        = string
  default     = "us-east4"
}

data "google_compute_zones" "availability_zones" {}

variable "zone" {
  description = "Zone where the VM is being provisioned"
  type        = string
  default     = "us-east4-a"
}

variable "credentials" {
  description = "GCP Credentials"
  type        = string
  default     = "keys/keys.json"
}

variable "env" {
  description = "Environment label used by this Terraform deployment"
  type        = string
  default     = "dev"
}

variable "neo4j_version" {
  description = "Neo4j version to be installed"
  type        = string
  default     = "5"
}

variable "adminPassword" {
  description = "Neo4j admin password"
  type        = string
  default     = "foobar123"
}

variable "nodeCount" {
  description = "Number of Neo4j nodes to be deployed"
  type        = number
  default     = 3
  validation {
     condition = anytrue([
      var.nodeCount == 1,
      var.nodeCount == 3,
      var.nodeCount == 4,
      var.nodeCount == 5,
      var.nodeCount == 6,
      var.nodeCount == 7])
     error_message = "Invalid number of nodes for a cluster"
  }
}

variable "installBloom" {
  description = "Install Neo4j Bloom"
  type        = string
  default     = "No"
  validation {
    condition = var.installBloom == "No" || var.installBloom == "Yes"
    error_message = "Choose Yes or No"
  }
}

variable "bloomLicenseKey" {
  description = "License key for the Neo4j Bloom plugin"
  type        = string
}

variable "installGraphDataScience" {
    description = "Install Neo4j GDS"
    type = string
    default = "No"
  validation {
    condition = var.installGraphDataScience == "No" || var.installGraphDataScience == "Yes"
    error_message = "Choose Yes or No"
  }
}

variable "graphDataScienceLicenseKey" {
    description = "GDS license to be used by this Terraform deployment"
    type = string
}

variable "vpc_name" {
  description = "Name of the VPC being used by this Terraform deployment"
  type        = string
  default     = "vpc-neo4j"
}

/*
Modify this, if you want to create a VPC spanning across multiple 
regions with Subnetworks in each region.
*/
variable "auto_create_subnetworks" {
  description = "If true, Terraform will automatically create subnetworks for the VPC"
  type = string
  default = "false"
}

variable "subnetwork_range" {
  description = "CIDR range of the subnetwork used by this Terraform deployment"
  type        = string
  default     = "10.10.10.0/24"
}

variable "neo4j_access_internal_ports" {
  description = "Internal access firewall rule ports used by this Terraform deployment"
  type        = list(string)
  default     = ["5000", "6000", "7000", "7687"]
}

variable "neo4j_access_external_ports" {
  description = "External access firewall rule ports used by this Terraform deployment"
  type        = list(string)
  default     = ["22", "7474", "7687"]
}

variable "vm_name" {
  description = "Name of the VM being provisioned by this Terraform deployment"
  type        = string
  default     = "neo4j-node"
}

variable "machine_type" {
  description = "Machine type of the VM being provisioned by this Terraform deployment"
  type        = string
#  default     = "e2-medium"
  default     = "n1-standard-4"
}

variable "vm_os_image" {
  description = "OS image used by this Terraform deployment"
  type        = string
  default     = "ubuntu-os-pro-cloud/ubuntu-pro-1804-lts"
#  default     = "projects/neo4j-aura-gcp/global/images/neo4j-enterprise-edition-byol-v20230202"
}

variable "neo4j_disk_size" {
  description = "Size of the storage disk used by this Terraform deployment"
  type        = number
  default     = 40
}

variable "neo4j_disk_type" {
  description = "Type of the storage disk used by this Terraform deployment (pd-ssd, pd-balanced, pd-standard)"
  type        = string
  default     = "pd-ssd"
}

/*
Setting the value to `false` prevents the boot disk from being 
deleted during server upsizing or downsizing.
Setting the value to `true` deletes the boot disk and recommended 
when destroying this deployment.
*/
variable "vm_boot_disk_delete_on_termination" {
  type    = string
  default = "true"
}

variable "firewall_target_tags" {
  description = "Firewall rule tags used by this Terraform deployment"
  type        = list(string)
  default     = ["neo4j-access"]
}

/*
Set this to 'true' to support resizing of the host VM Compute Engine instance.
*/
variable "allow_stopping_for_update" {
  type    = string
  default = "true"
}

/*
Keep the following settings to 'false' if you're 
not using preemptible instances
*/
variable "scheduling_preemptible" {
  type    = string
  default = "false"
}

/*
Keep the following settings to 'false' if you're 
not using preemptible instances
*/
variable "scheduling_automatic_restart" {
  type    = string
  default = "false"
}

variable "labels_group" {
  description = "Group labels used by this Terraform deployment"
  type        = string
  default     = "neo4j-cluster"
}

variable "private_zone_dns" {
  description = "Private DNS setup for setting up Cluster resolver"
  type        = string
  default     = "neo4j.cluster.com."
}

variable "recordset_name" {
  description = "Private DNS setup recordset name"
  type        = string
  default     = "neo4j.cluster.com."
}

variable "enable_health_check" {
  description = "Flag to indicate if health check is enabled. If set to true, a firewall rule allowing health check probes is also created."
  type        = bool
  default     = false
}