variable "kubeconfig_path" {
  description = "Path to kubeconfig"
  type        = string
  default     = "~/.kube/config"
}

variable "argocd_namespace" {
  description = "ArgoCD namespace"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "9.4.15"
}

variable "argocd_image_updater_chart_version" {
  description = "ArgoCD Image Updater Helm chart version"
  type        = string
  default     = "1.1.3"
}
