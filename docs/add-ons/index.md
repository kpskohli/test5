# Kubernetes Addons Module

The [`kubernetes-addons`](../../kubernetes-addons) module within this framework allows you to configure the add-ons you would like deployed into you EKS cluster with simple **true/false** flags.

The framework currently provides support for the following add-ons:

| Add-on    | Description   |
|-----------|-----------------
| [Agones](./agones) | An open source, batteries-included, multiplayer dedicated game server scaling and orchestration platform that can run anywhere Kubernetes can run. |
| [ArgoCD](./argocd) | A declarative, GitOps continuous delivery tool for Kubernetes. |
| [AWS for Fluent Bit](./aws-for-fluent-bit) | Send container logs to AWS services for log storage and analytics. |
| [AWS Load Balancer Controller](./aws-load-balancer-controller) | Manages AWS Elastic Load Balancers for a Kubernetes cluster.  |
| [AWS Node Termination Handler](./aws-node-termination-handler) | Ensures that the Kubernetes control plane responds appropriately to events that can cause your EC2 instance to become unavailable. |
| [AWS Distro for Open Telemetry](./aws-open-telemetry) | A secure, production-ready, AWS-supported distribution of the OpenTelemetry project. |
| [cert-manager](./cert-manager) | Adds certificates and certificate issuers as resource types in Kubernetes clusters, and simplifies the process of obtaining, renewing and using those certificates. |
| [Cluster Autoscaler](./cluster-autoscaler) | Automatically adjusts the size of the Kubernetes cluster. |
| [EKS Add-ons](./eks-add-ons) | Installation and management of a curated set of add-ons for Amazon EKS clusters. |
| [Fargate Fluent Bit](./fargate-fluent-bit) | Send Fargate container logs to AWS services for log storage and analytics. |
| [Ingress Nginx](./ingress-nginx) | Manages Ingress resources in an EKS cluster. |
| [Keda](./keda) | An event-driven autoscaler for Kubernetes |
| [Metrics Server](./metrics-server) | A scalable, efficient source of container resource metrics for Kubernetes built-in autoscaling pipelines |
| [Prometheus](./prometheus) | An open-source monitoring system with a dimensional data model, flexible query language, efficient time series database and modern alerting approach. |
| [Spark K8s Operator](./spark-k8s-operator) | Run Spark applications on a Kubernetes cluster. |
| [Traefik](./traefik) | A modern HTTP reverse proxy and load balancer. |
| [Vertical Pod Autoscaler](./vertical-pod-autoscaler) | Automatically adjusts the CPU and memory reservations for your pods to help "right size" your applications. |
| [Yunikorn](./yunikorn) |Rich scheduling capabilities on Kubernetes. |

## Add-on Management

The framework provides two approaches to managing add-on configuration for your EKS clusters. They are:

1. Via Terraform by leveraging the [Terraform Helm provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs).
2. Via GitOps with [ArgoCD](https://argo-cd.readthedocs.io/en/stable/).

### Terraform

The default method for managing add-on configuration is via Terraform. By default, each individual add-on module will do the following:

1. Create any AWS resources needed to support add-on functionality.
2. Deploy a Helm chart into your EKS cluster by leveraging the Terraform Helm provider.

In order to deploy an add-on with default configuration, simply enable the add-on via Terraform properties.

```hcl
metrics_server_enable       = true # Deploys Metrics Server Addon
cluster_autoscaler_enable   = true # Deploys Cluster Autoscaler Addon
prometheus_enable           = true # Deploys Prometheus Addon
```

To customize the behavior of the Helm charts that are ultimately deployed, you can supply custom Helm configuration. The following demonstrates how you can supply this configuration, including a dedicated `values.yaml` file.

```hcl
metrics_server_helm_chart = {
	name           = "metrics-server"
	repository     = "https://kubernetes-sigs.github.io/metrics-server/"
	chart          = "metrics-server"
	version        = "3.5.0"
	namespace      = "kube-system"
	timeout        = "1200"

	# (Optional) Example to pass metrics-server-values.yaml from your local repo
	values = [templatefile("${path.module}/k8s_addons/metrics-server-values.yaml", {
			operating_system = "linux"
	})]
}
```

Each add-on module is configured to fetch Helm Charts from Open Source, public Helm repositories and Docker images from Docker Hub/Public ECR repositories. This requires outbound Internet connection from your EKS Cluster.

If you would like to use private repositories, you can download Docker images for each add-on and push them to an AWS ECR repository. ECR can be accessed from within a private existing VPC using an ECR VPC endpoint. For instructions on how to download existing images and push them to ECR, see [ECR instructions](../advanced/ecr-instructions.md).

### GitOps with ArgoCD

To indicate that you would like to manage add-ons via ArgoCD, you must do the following:

1. Enable the ArgoCD add-on by setting `argocd_enable` to `true`.
2. Specify you would like ArgoCD to be responsible for deploying your add-ons by setting `argocd_manage_add_ons` to `true`. This will prevent the individual Terraform add-on modules from deploying Helm charts.
3. Pass Application configuration for your add-ons repository via the `argocd_applications` property.

Note, that the `add_on_application` flag in your `Application` configuration must be set to `true`.

```
argocd_enable           = true
argocd_manage_add_ons   = true
argocd_applications     = {
  infra = {
    namespace             = "argocd"
    path                  = "<path>"
    repo_url              = "<repo_url>"
    values                = {}
    add_on_application    = true # Indicates the root add-on application.
  }
}
```

#### GitOps Bridge

When managing add-ons via ArgoCD, certain AWS resources may still need to be created via Terraform in order to support add-on functionality (e.g. IAM Roles and Services Account). Certain resource values will also need to passed from Terraform to ArgoCD via the ArgoCD Application resource's values map. We refer to this concept as the `GitOps Bridge`

To ensure that AWS resources needed for add-on functionality are created, you still need to indicate in Terraform configuration which add-ons will be managed via ArgoCD. To do so, simply enable the add-ons via their boolean properties.

```
metrics_server_enable       = true # Deploys Metrics Server Addon
cluster_autoscaler_enable   = true # Deploys Cluster Autoscaler Addon
prometheus_enable           = true # Deploys Prometheus Addon
```

This will indicate to each add-on module that it should create the necessary AWS resources and pass the relevant values to the ArgoCD Application resource via the Application's values map.
