# Getting Started

This getting started guide will help you deploy your first EKS environment using the `terraform-ssp-amazon-eks` module.

## Prerequisites:

Ensure that you have installed the following tools installed on your local machine before working with this module.

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
3. [kubectl](https://kubernetes.io/docs/tasks/tools/)
4. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Clone the repo

```shell script
git clone https://github.com/aws-samples/aws-eks-accelerator-for-terraform.git
```

### Run Terraform INIT

CD into the sample directory.

```shell script
cd examples/eks-cluster-with-new-vpc/
```

Initialize the working directory with configuration files.

```shell script
terraform init
```

### Run Terraform PLAN

Verify the resources that will be created by this execution.

```shell script
terraform plan
```

### Run Terraform APPLY

Deploy your EKS environment.

```shell script
terraform apply
```

### Configure kubectl

Details for your EKS Cluster can be extracted from terraform output or from AWS Console to get the name of cluster.

This following command used to update the `kubeconfig` in your local machine where you run `kubectl` commands to interact with your EKS Cluster.

```
$ aws eks --region <region> update-kubeconfig --name <cluster-name>
```

### Validate your deployment

List all the worker nodes by running the following:

```
$ kubectl get nodes
```

List all the pods running in kube-system namespace:

```
$ kubectl get pods -n kube-system
```

Congratulations! You have deployed your first EKS environment with the SSP on EKS for Terraform.

## Examples

To view additional examples for how you can leverage this framework, see the [examples](./examples) directory.