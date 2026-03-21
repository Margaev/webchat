variable "kubeconfig_path" {
  description = "Path to kubeconfig"
  type        = string
  default     = "~/.kube/config"
}

variable "argo_cd_namespace" {
  description = "ArgoCD namespace"
  type        = string
  default     = "argo-cd"
}

variable "argo_cd_chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "9.4.15"
}
