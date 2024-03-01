// Define a Kubernetes cluster on DigitalOcean.
resource "digitalocean_kubernetes_cluster" "k8s_cluster" {
  name    = var.name        // Cluster name.
  region  = var.region      // Region where the cluster will be created.
  version = var.k8s_version // Kubernetes version.
  tags    = ["prevent"]     // Tags to identify resources in DigitalOcean.

  // Define the cluster's node pool.
  node_pool {
    name       = var.name                          // Node pool name.
    size       = var.size                          // Node size.
    tags       = ["prevent", "worker"] // Tags to identify resources in DigitalOcean.
    node_count = var.node_count                    // Number of nodes in the pool.
    auto_scale = true                              // Enable automatic scaling.
    min_nodes  = var.min_nodes                     // Minimum number of nodes in the pool.
    max_nodes  = var.max_nodes                     // Maximum number of nodes in the pool.
  }
}

resource "digitalocean_firewall" "kubernetes_cluster" {
  name = "kubernetes-cluster-fw"
  tags = ["prevent"]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "1-65535"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "udp"
    port_range       = "1-65535"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "80"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "443"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }


  depends_on = [digitalocean_kubernetes_cluster.k8s_cluster]
}