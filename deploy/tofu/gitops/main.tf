resource "kubernetes_manifest" "argocd_project" {
  manifest = yamldecode(templatefile("${path.module}/templates/argocd-project.yaml.tftpl", {
    argocd_namespace = var.argocd_namespace
  }))
}

resource "kubernetes_manifest" "argocd_application_set" {
  manifest = yamldecode(templatefile("${path.module}/templates/argocd-application-set.yaml.tftpl", {
    argocd_namespace = var.argocd_namespace
  }))

  depends_on = [
    kubernetes_manifest.argocd_project,
  ]
}

resource "kubernetes_manifest" "argocd_image_updater" {
  manifest = yamldecode(templatefile("${path.module}/templates/argocd-image-updater.yaml.tftpl", {
    argocd_namespace = var.argocd_namespace
  }))

  depends_on = [
    kubernetes_manifest.argocd_application_set,
  ]
}
