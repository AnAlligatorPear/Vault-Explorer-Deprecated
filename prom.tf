# Monitoring Stack
# Deploying sidecar injector helm chart
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.vault.id
  version    = var.prom_version


  # Load the existing YAML configuration and marge the templatefile with the prometheus yaml
  values = [
    yamlencode(
      merge(
        yamldecode(file("${path.module}/prom.stack.values.yml")),
        yamldecode(templatefile("${path.module}/grafana-values.tftpl", {
          vault_addr = var.vault_addr
          vault_key  = var.vault_key
        }))
      )
    )
  ]
}
variable "vault_addr" {
  type        = string
  description = "The Vault address being accessed by Grafana/Prometheus"
  sensitive   = false
}

variable "vault_key" {
  type        = string
  description = "The Vault token to use for authentication"
  sensitive   = true
}



resource "kubernetes_secret_v1" "vault_token" {
  metadata {
    name      = "vaulttoken"
    namespace = kubernetes_namespace.vault.id
  }

  data = {
    token = var.vault_admin_token
  }

  type = "kubernetes.io/opaque"
}


resource "kubernetes_config_map" "grafana-dashboards-vault" {
  metadata {
    name      = "grafana-dashboard-vault"
    namespace = kubernetes_namespace.vault.id

    labels = {
      grafana_dashboard = 1
    }
  }

  data = {
    "vault.grafana.json" = file("vault.grafana.json")
  }
}