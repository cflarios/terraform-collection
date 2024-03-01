// Define a Kubernetes cluster on DigitalOcean.
resource "digitalocean_kubernetes_cluster" "k8s" {
  name    = "k8s"           // Cluster name.
  region  = var.region      // Region where the cluster will be created.
  version = var.k8s_version // Kubernetes version.
  tags    = ["k8s"]         // Tags to identify resources in DigitalOcean.

  // Define the cluster's node pool.
  node_pool {
    name       = "nginx"                    // Node pool name.
    size       = "s-1vcpu-2gb"              // Node size.
    tags       = ["k8s", "worker", "nginx"] // Tags to identify resources in DigitalOcean.
    node_count = var.node_count             // Number of nodes in the pool.
    auto_scale = true                       // Enable automatic scaling.
    min_nodes  = var.min_nodes              // Minimum number of nodes in the pool.
    max_nodes  = var.max_nodes              // Maximum number of nodes in the pool.
  }
}

// Deploy the API as a Kubernetes deployment.
resource "kubernetes_deployment" "api" {
  metadata {
    name      = "api-terraform" // Deployment name.
    namespace = "kube-system"   // Namespace for the deployment.

    labels = {
      app = "api" // Label for the deployment.
    }
  }

  spec {
    replicas = 2 // Number of replicas to create.

    selector {
      match_labels = {
        app = "api" // Match the deployment label.
      }
    }

    template {
      metadata {
        labels = {
          app = "api" // Label for the deployment.
        }
      }

      spec {
        container {
          image = "nginx:latest" // Docker image for the container.
          name  = "app"                                     // Name of the container.
          port {
            container_port = 3001 // Port to expose on the container.
          }

          resources {
            limits = {
              cpu    = "0.5"   // CPU limit for the container.
              memory = "512Mi" // Memory limit for the container.
            }
            requests = {
              cpu    = "250m" // CPU request for the container.
              memory = "50Mi" // Memory request for the container.
            }
          }
        }
      }
    }
  }

  timeouts {
    create = "20m" // Timeout for creating the deployment.
    update = "20m" // Timeout for updating the deployment.
  }
}

// Create a Kubernetes service for the API.
resource "kubernetes_service" "api" {

  metadata {
    name      = "api-terraform" // Service name.
    namespace = "kube-system"   // Namespace for the service.
  }
  spec {
    selector = {
      app = kubernetes_deployment.api.metadata[0].labels.app // Match the deployment label.
    }

    session_affinity = "ClientIP" // Session affinity setting.

    port {
      port        = 80   // Port to expose on the service.
      target_port = 3001 // Port to target on the containers.
    }

    type = "LoadBalancer" // Type of service.
  }
}

// Create a DigitalOcean load balancer.
resource "digitalocean_loadbalancer" "lb" {
  name      = "my-lb"       // Load balancer name.
  region    = var.region    // Region where the load balancer will be created.
  algorithm = "round_robin" // Load balancing algorithm to use.

  forwarding_rule {
    entry_port      = 80     // Port to listen
    entry_protocol  = "http" // Protocol to listen
    target_port     = 80     // Port to target
    target_protocol = "http" // Protocol to target
  }

  healthcheck {
    protocol = "tcp" // Protocol to use for health checks.
    port     = 22    // Port to use for health checks.
  }

  droplet_tag = "k8s" // Tag to identify droplets to add to the load balancer.
}
