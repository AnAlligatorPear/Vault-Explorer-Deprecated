# Creating K8s Namespaces 
resource "kubernetes_namespace" "vault" {
  metadata {
    annotations = {
      name = "vault"
    }

    labels = {
      team = "vault"
    }

    name = "vault"
  }
}





