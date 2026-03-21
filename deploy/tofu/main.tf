resource "kubernetes_namespace_v1" "argo_cd" {
  metadata {
    name = var.argo_cd_namespace
  }
}

resource "helm_release" "argo_cd" {
  name             = "argo-cd"
  namespace        = kubernetes_namespace_v1.argo_cd.metadata[0].name
  create_namespace = false

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argo_cd_chart_version

  values = [
    file("${path.module}/values.yaml")
  ]
}

