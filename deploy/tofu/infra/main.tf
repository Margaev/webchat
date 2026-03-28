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

resource "kubernetes_manifest" "application_set" {
  manifest = yamldecode(<<-EOT
    apiVersion: argoproj.io/v1alpha1
    kind: ApplicationSet
    metadata:
      name: gitops
      namespace: ${var.argocd_namespace}
    spec:
      goTemplate: true
      goTemplateOptions: ["missingkey=error"]
      generators:
      - git:
          repoURL: https://github.com/Margaev/webchat.git
          revision: HEAD
          directories:
          - path: deploy/manifests/*
      template:
        metadata:
          name: '{{.path.basename}}'
        spec:
          project: "webchat"
          source:
            repoURL: https://github.com/argoproj/argo-cd.git
            targetRevision: HEAD
            path: '{{.path.path}}'
          destination:
            server: https://kubernetes.default.svc
            namespace: '{{.path.basename}}'
          syncPolicy:
            syncOptions:
            - CreateNamespace=true
    EOT
  )

  depends_on = [helm_release.argocd]
}
