# Provider configuration
terraform {
    required_version = ">= 0.14.0"

    required_providers {
        digitalocean = {
            source = "digitalocean/digitalocean"
        }
    }
}

# Configure the DigitalOcean provider
provider "digitalocean" {
    token = "${var.digitalocean_token}"
}

# Configure the Kubernetes provider
provider "kubernetes" {
    config_path = "${local_file.kubernetes_config.filename}"
}
