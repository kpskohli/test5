
terraform {
  required_version = ">= 1.0.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.66.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.7.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
  }
}

data "aws_region" "current" {}

provider "aws" {
  region = data.aws_region.current.id
  alias  = "default"
}

terraform {
  backend "local" {
    path = "local_tf_state/terraform-main.tfstate"
  }
}

#---------------------------------------------------------------
# Example to consume aws-eks-accelerator-for-terraform module
#---------------------------------------------------------------

module "aws-eks-accelerator-for-terraform" {
  source = "../.."

  # Environment Configuration
  tenant            = local.tenant
  environment       = local.environment
  zone              = local.zone
  terraform_version = local.terraform_version

  #---------------------------------------------------------------
  # VPC/SUBNETS
  #---------------------------------------------------------------

  vpc_id             = module.aws_vpc.vpc_id
  private_subnet_ids = module.aws_vpc.private_subnets

  #---------------------------------------------------------------
  # ADDONS
  #---------------------------------------------------------------

  # EKS ADD-ONS
  enable_eks_addon_vpc_cni            = true
  enable_eks_addon_coredns            = true
  enable_eks_addon_kube_proxy         = true
  enable_eks_addon_aws_ebs_csi_driver = true

  # KUBERNETES ADD-ONS
  argocd_enable                    = true
  aws_lb_ingress_controller_enable = true
  cert_manager_enable              = true
  cluster_autoscaler_enable        = true
  metrics_server_enable            = true
  nginx_ingress_controller_enable  = true

  #---------------------------------------------------------------
  # CLUSTER CONFIG
  #---------------------------------------------------------------

  # EKS CONTROL PLANE CONFIG
  create_eks         = true
  kubernetes_version = local.kubernetes_version

  # MANAGED NODE GROUPS
  managed_node_groups = {
    mng = {
      node_group_name = "managed-ondemand"
      instance_types  = ["m4.large"]
      subnet_ids      = module.aws_vpc.private_subnets
    }
  }

  # FARGATE PROFILES
  fargate_profiles = {
    default = {
      fargate_profile_name = "default"
      fargate_profile_namespaces = [
        {
          namespace = "default"
          k8s_labels = {
            Environment = "preprod"
            Zone        = "dev"
            env         = "fargate"
          }
      }]
      subnet_ids      = module.aws_vpc.private_subnets
      additional_tags = { ExtraTag = "Fargate" }
    }
  }
}
