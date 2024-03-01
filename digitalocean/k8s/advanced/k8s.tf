# Definición de las imágenes a utilizar

locals {
  app_image = "profile/frontend:latest"
  api_image = "profile/backend:latest"
}

resource "kubernetes_namespace" "namespace" {
  for_each = var.environments

  metadata {
    name = each.key
  }
}

resource "kubernetes_deployment" "app" {

  for_each = var.environments

  metadata {
    name      = "app"
    namespace = kubernetes_namespace.namespace[each.key].metadata[0].name
  }

  spec {
    replicas = each.value.replicas

    selector {
      match_labels = {
        app = "app"
      }
    }

    template {
      metadata {
        labels = {
          app = "app"
        }
      }

      spec {
        image_pull_secrets {
          name = kubernetes_secret.dockerhub_credentials[each.key].metadata[0].name
        }
        container {
          name  = "app"
          image = local.app_image

          # Container configuration

          port {
            container_port = 3000 // Port to expose on the container.
          }

          resources {
            limits = {
              cpu    = "1"     // CPU limit for the container.
              memory = "512Mi" // Memory limit for the container.
            }
            requests = {
              cpu    = "0.5"   // CPU request for the container.
              memory = "256Mi" // Memory request for the container.
            }
          }
        }
      }
    }
  }

  timeouts {
    create = "30m" // Timeout for creating the deployment.
    update = "30m" // Timeout for updating the deployment.
  }

  depends_on = [
    kubernetes_namespace.namespace
  ]
}

resource "kubernetes_deployment" "api" {

  for_each = var.environments

  metadata {
    name      = "api"
    namespace = kubernetes_namespace.namespace[each.key].metadata[0].name
  }

  spec {
    replicas = each.value.replicas

    selector {
      match_labels = {
        app = "app"
      }
    }

    template {
      metadata {
        labels = {
          app = "app"
        }
      }

      spec {

        image_pull_secrets {
          name = kubernetes_secret.dockerhub_credentials[each.key].metadata[0].name
        }
        container {
          name  = "api"
          image = local.api_image

          # Container configuration

          port {
            container_port = 3001 // Port to expose on the container.
          }

          resources {
            limits = {
              cpu    = "1"     // CPU limit for the container.
              memory = "512Mi" // Memory limit for the container.
            }
            requests = {
              cpu    = "0.5m"  // CPU request for the container.
              memory = "256Mi" // Memory request for the container.
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

  depends_on = [
    kubernetes_namespace.namespace
  ]
}

resource "kubernetes_service" "loadBalancer" {

  for_each = var.environments

  metadata {
    name      = "app-and-api"                                             // Service name.
    namespace = kubernetes_namespace.namespace[each.key].metadata[0].name // Namespace for the service.

    annotations = {
      "service.beta.kubernetes.io/do-loadbalancer-protocol"                 = "http"
      "service.beta.kubernetes.io/do-loadbalanceer-http-ports"              = "80,8080"
      "service.beta.kubernetes.io/do-loadbalancer-name"                     = kubernetes_namespace.namespace[each.key].metadata[0].name
      "service.beta.kubernetes.io/do-loadbalancer-enable-backend-keepalive" = "false"
    }
  }
  spec {
    selector = {
      app = "app" // Match the deployment label.
    }

    session_affinity = "ClientIP" // Session affinity setting.

    external_traffic_policy = "Cluster"
    port {
      name        = "http"
      port        = 80   // Port to expose on the service.
      target_port = 3000 // Port to target on the containers.
    }

    port {
      name        = "https"
      port        = 8080 // Port to expose on the service.
      target_port = 3001 // Port to target on the containers.
    }

    type = "LoadBalancer" // Type of service.

    load_balancer_source_ranges = ["0.0.0.0/0"]
  }

  depends_on = [
    kubernetes_deployment.app,
    kubernetes_deployment.api
  ]
}


resource "kubernetes_ingress_v1" "ingress" {

  for_each = var.environments

  metadata {
    name      = "app-ingress"
    namespace = kubernetes_namespace.namespace[each.key].metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    # backend {
    #   service_name = "app-and-api"
    #   service_port = 80
    # }

    rule {
      host = "k8s.sexft.io"
      http {
        path {
          path = "/"
          backend {
            service {
              name = "app-and-api"
              port {
                number = 80
              }
            }
          }
        }

        path {
          path = "/api"
          backend {
            service {
              name = "app-and-api"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.nginx_ingress
  ]
}

resource "kubernetes_cluster_role" "cluster_role" {
  metadata {
    name = "discover_base_url"
    annotations = {
      "rbac.authorization.kubernetes.io/autoupdate" = "true"
    }
    labels = {
      "kubernetes.io/bootstrapping" = "rbac-defaults"
    }
  }

  rule {
    non_resource_urls = ["/"]
    verbs             = ["get"]
  }
}

resource "kubernetes_cluster_role_binding" "cluster_role_binding" {
  metadata {
    name = "discover_base_url"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.cluster_role.metadata[0].name
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "User"
    name      = "system:anonymous"
  }
}


resource "kubernetes_role" "ingress" {

  for_each = var.environments
  metadata {
    name      = "ingress-role"
    namespace = kubernetes_namespace.namespace[each.key].metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "endpoints", "secrets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

resource "kubernetes_role_binding" "ingress" {

  for_each = var.environments
  metadata {
    name      = "ingress-role-binding"
    namespace = kubernetes_namespace.namespace[each.key].metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.ingress[each.key].metadata[0].name
  }

  subject {
    kind      = "User"
    name      = "admin"
    namespace = kubernetes_namespace.namespace[each.key].metadata[0].name
  }
}


resource "helm_release" "nginx_ingress" {

  name       = "nginx-ingress-controller"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"

  set {
    name  = "service.type"
    value = "ClusterIP"
  }
}
