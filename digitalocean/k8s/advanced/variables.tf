// DigitalOcean API token
variable "digitalocean_token" {}

// Cloudflare

variable "cloudflare_email" {
  description = "Cloudflare email"
  default     = "your@gmail.com"
}

variable "cloudflare_token" {}
// Cluster & vm name 
variable "name" {
  default = "app-cluster"
}

// Cluster region
variable "region" {
  default = "nyc1"
}

// Virtual Machine size
variable "size" {
  default = "s-4vcpu-8gb"
}
// Load balancer name
variable "lb_name" {
  default = "urk-lb"
}

// Kubernetes version
variable "k8s_version" {
  default = "1.26.3-do.0"
}

// Node pool size
variable "node_count" {
  description = "number of nodes in the cluster"
  default     = 1
}

// Minimum number of nodes
variable "min_nodes" {
  description = "minimum number of nodes in the cluster"
  default     = 2
}

// Maximum number of nodes
variable "max_nodes" {
  description = "maximum number of nodes in the cluster"
  default     = 3
}

variable "registry_server" {
  description = "Docker registry server"
  default     = "https://index.docker.io/v1/"
}

variable "dockerhub_username" {
  description = "Docker username"
  default     = "your_username"
  # type        = string
  # sensitive   = true
}

variable "dockerhub_password" {
  description = "Docker password"
  default     = "your_password"
  # type        = string
  # sensitive   = true
}

variable "dockerhub_email" {
  description = "Docker email"
  default     = "your-email@gmail.com"
  # type        = string
  # sensitive   = true
}

variable "environments" {
  type = map(object({
    replicas = number
  }))

  default = {
    test = {
      replicas = 1
    },
    prod = {
      replicas = 1
    }
  }
}

variable "namespaces" {
  type    = list(string)
  default = ["test", "prod"]
}

# Variables específicas para cada ambiente

variable "test_node_count" {
  description = "The number of nodes in the Kubernetes cluster for the test environment."
  default     = 1
}

variable "prod_node_count" {
  description = "The number of nodes in the Kubernetes cluster for the prod environment."
  default     = 5
}

variable "dev_node_count" {
  description = "The number of nodes in the Kubernetes cluster for the dev environment."
  default     = 1
}