module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  helm_config       = local.helm_config
  irsa_config       = local.irsa_config
  addon_context     = var.addon_context
}

resource "aws_iam_policy" "secrets_store_csi_driver" {
  name        = "${var.addon_context.eks_cluster_id}-secrets-store-csi-driver-policy"
  description = "IAM Policy for Secrets Store CSI Driver"
  policy      = data.aws_iam_policy_document.secrets_store_csi_driver.json
  tags        = var.addon_context.tags
}

