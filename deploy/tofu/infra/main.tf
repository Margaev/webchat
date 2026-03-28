resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = var.argocd_namespace
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = kubernetes_namespace_v1.argocd.metadata[0].name
  create_namespace = false

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version

  values = [
    file("${path.module}/values.yaml")
  ]
}

resource "kubernetes_manifest" "argocd_project" {
  manifest = yamldecode(templatefile("${path.module}/templates/argocd-project.yaml.tftpl", {
    argocd_namespace = var.argocd_namespace
  }))

  depends_on = [helm_release.argocd]
}

resource "kubernetes_manifest" "argocd_application_set" {
  manifest = yamldecode(templatefile("${path.module}/templates/argocd-application-set.yaml.tftpl", {
    argocd_namespace = var.argocd_namespace
  }))

  depends_on = [
    helm_release.argocd,
    kubernetes_manifest.argocd_project,
  ]
}
