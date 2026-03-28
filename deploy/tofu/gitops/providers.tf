terraform {
  required_providers {
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "~> 7.15"
    }
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

provider "argocd" {
  port_forward_with_namespace = "custom-argocd-namespace"
  kubernetes = {
    config_path = var.kubeconfig_path
  }
  username = "admin"
  password = var.argocd_password
}
