# Creating K8s Namespaces 
resource "kubernetes_namespace" "vault" {
  metadata {
    annotations = {
      name = "vaultexplorer"
    }

    labels = {
      team = "vaultexplorer"
    }

    name = "vaultexplorer"
  }
}





