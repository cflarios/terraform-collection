variable "digitalocean_token" {}

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