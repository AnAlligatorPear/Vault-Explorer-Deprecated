terraform {
 required_version = "~> 1.5"
 required_providers {
        helm = {
            source  = "hashicorp/helm"
            version = "~> 2.12.1"
        }
        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = "~> 2.25.2"
        }
    }
}

data "kubernetes_service" "vault" {
  depends_on = [ helm_release.vault ]
  metadata {
    name = "vault"
    namespace = kubernetes_namespace.vault.id
  }
}


provider "kubernetes" {
  config_path           = "~/.kube/config"
  config_context        = "docker-desktop"
}


provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "docker-desktop"
  }
}


