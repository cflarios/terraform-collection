// This file contains all the variables used in the terraform code

// DigitalOcean API token
variable "digitalocean_token" {}

// Cluster region
variable "region" {
  default = "nyc1"
}

// Kubernetes version
variable "k8s_version" {
  default = "1.23.14-do.0"
}

// Node pool size
variable "node_count" {
  description = "number of nodes in the cluster"
  default = 2
}

// Minimum number of nodes
variable "min_nodes" {
  description = "minimum number of nodes in the cluster"
  default = 2
}

// Maximum number of nodes
variable "max_nodes" {
  description = "maximum number of nodes in the cluster"
  default = 3
}
