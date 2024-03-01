// Output the cluster name
output "k8s_cluster_name" {
  value = digitalocean_kubernetes_cluster.k8s_cluster.name
}

// Output the cluster endpoint
output "k8s_cluster_endpoint" {
  value = digitalocean_kubernetes_cluster.k8s_cluster.endpoint
}

// Define a local file to store the cluster's kubeconfig
resource "local_file" "kubernetes_config" {
  filename = "kubeconfig.yaml"
  content  = digitalocean_kubernetes_cluster.k8s_cluster.kube_config.0.raw_config
}