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


provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "docker-desktop"
}


provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "docker-desktop"
  }
}


