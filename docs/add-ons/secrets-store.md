# Secrets Store CSI Driver Add-on

The Secrets Store CSI Driver Add-on provisions the Kubernetes Secrets Store CSI Driver [Container Storage Interface (CSI) Driver](https://github.com/kubernetes-sigs/secrets-store-csi-driver) which is used for providing secrets to applications operating on Amazon Elastic Kubernetes Service.

Kubernetes Secrets Store integrates secrets stores with Kubernetes through a Container Storage Interface (CSI) volume. 

## Usage

The Secrets Store CSI Driver Add-on can be enabled through the following:

### Example
```hcl-terraform
module "kubernetes-addons" {
  source = "./modules/kubernetes-addons"
  eks_cluster_id = module.aws-eks-accelerator-for-terraform.eks_cluster_id
  
  enable_secrets_store_csi_driver = true
  secrets_store_csi_driver_helm_config = {...} # custom helm config values can go here
}
```