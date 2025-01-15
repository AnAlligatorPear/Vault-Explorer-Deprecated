variable kubernetes_endpoint {
  default     =  "https://kubernetes.docker.internal:6443"
  type        = string
  description = "Kubernetes/Openshift Endpoint" 
}


variable vault_admin_token {
  type        = string
  default     = "$VAULT_TOKEN"
  description = "Vault Token" 
}

# Promethues Stack Helm Version
variable "prom_version" {
  type = string
  description = "Prom Version"
  default = "61.3.0"
}








