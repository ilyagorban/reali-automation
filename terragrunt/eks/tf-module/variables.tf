variable "region" {
  default = "us-west-2"
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "tags" {
  description = "Additional tags (provided by terragrunt)"
  type = map(string)
}

variable "env_name" {
  description = "Environment name"
  type = string
}

variable "vpc_id" {
  description = "VPC id"
  type = string
}

variable "cluster_name" {
  description = "cluster name"
  type = string
}

variable "subnets" {
  description = "Subnets to use for deployment of nodes"
  type = list(string)
}

variable "argo_instance_types" {
  description = "Instance types for argo"
  type = list(string)
  default = ["t3.small"]
}

variable "application_instance_types" {
  description = "Instance types for application"
  type = list(string)
  default = ["t3.small"]
}
