terraform {
  # use of local tf-module in order not to create additional repo for terraform modules
  source = "${get_original_terragrunt_dir()}/tf-module"
}

include {
  path = find_in_parent_folders()
}
locals {
  common_vars_file  = file(find_in_parent_folders("common.yaml"))
  common_vars  = yamldecode(local.common_vars_file)
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    private_subnets = ["known after apply"]
    vpc_id          = "known after apply"
  }
}

inputs = {
  cluster_name = local.common_vars.env_name
  subnets                               = dependency.vpc.outputs.private_subnets
  vpc_id                                = dependency.vpc.outputs.vpc_id
  argo_instance_types                   = ["t3.small"]
  application_instance_types            = ["t3.small"]
  cluster_enabled_log_types: ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}
