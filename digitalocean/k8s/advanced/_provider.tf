# Provider configuration
terraform {
  required_version = ">= 0.14.0"

  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.4.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.8.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.13.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

# Configure the DigitalOcean provider
provider "digitalocean" {
  token = var.digitalocean_token
}

# Configure the Kubernetes provider
provider "kubernetes" {
  config_path = local_file.kubernetes_config.filename
}

# Configure the Helm provider

provider "helm" {
  kubernetes {
    config_path = local_file.kubernetes_config.filename
  }
}

provider "kubectl" {
  host                   = yamldecode(digitalocean_kubernetes_cluster.k8s_cluster.kube_config).clusters.0.cluster.server
  client_certificate     = base64decode(yamldecode(cdigitalocean_kubernetes_cluster.k8s_cluster.kube_config).users.0.user.client-certificate-data)
  client_key             = base64decode(yamldecode(digitalocean_kubernetes_cluster.k8s_cluster.kube_config).users.0.user.client-key-data)
  cluster_ca_certificate = base64decode(yamldecode(digitalocean_kubernetes_cluster.k8s_cluster.kube_config).clusters.0.cluster.certificate-authority-data)
  load_config_file       = false
}

provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}