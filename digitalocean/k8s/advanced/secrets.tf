resource "kubernetes_secret" "dockerhub_credentials" {
  for_each = toset(var.namespaces)
  metadata {
    name      = "docker-cfg"
    namespace = each.key
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.registry_server}" = {
          "username" = var.dockerhub_username
          "password" = var.dockerhub_password
          "email"    = var.dockerhub_email
          "auth"     = base64encode("${var.dockerhub_username}:${var.dockerhub_password}")
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}