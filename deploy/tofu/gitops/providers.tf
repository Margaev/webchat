terraform {
  required_providers {
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "~> 7.15"
    }
  }
}

provider "argocd" {
  port_forward_with_namespace = "custom-argocd-namespace"
  kubernetes {
    config_context = "kind-argocd"
  }
  username = "admin"
  password = var.argocd_password
}
