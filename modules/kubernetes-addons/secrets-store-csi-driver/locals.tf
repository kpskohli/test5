locals {
  name                 = "secrets-store-csi-driver"
  service_account_name = "secrets-store-csi-driver-sa"
  namespace            = "kube-system"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
    version     = "1.1.2"
    namespace   = local.namespace
    values      = local.default_helm_values
    description = "The Secrets Store CSI driver Helm chart deployment configuration"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_helm_values = []

  irsa_config = {
    kubernetes_namespace              = local.namespace
    kubernetes_service_account        = local.service_account_name
    create_kubernetes_namespace       = false
    create_kubernetes_service_account = true
    iam_role_path                     = "/"
    eks_cluster_id                    = var.addon_context.eks_cluster_id
    irsa_iam_policies                 = concat([aws_iam_policy.secrets_store_csi_driver.arn], var.irsa_policies)
    tags                              = var.addon_context.tags
  }

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account_name
  }
}
