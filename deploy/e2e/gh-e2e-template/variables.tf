variable "cluster_version" {
  type        = string
  description = "Kubernetes Version"
  default     = "1.21"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "tenant" {
  type        = string
  description = "Account Name or unique account unique id e.g., apps or management or aws007"
}

variable "environment" {
  type        = string
  description = "Environment area, e.g. prod or preprod "
}

variable "zone" {
  type        = string
  description = "zone, e.g. dev or qa or load or ops etc..."
}
