variable "kubeconfig_path" {
  description = "Path to kubeconfig"
  type        = string
  default     = "~/.kube/config"
}

variable "argocd_password" {
  description = "ArgoCD password"
  type        = string
}

