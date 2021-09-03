locals {
  common_vars_file  = file(find_in_parent_folders("common.yaml"))
  common_vars  = yamldecode(local.common_vars_file)

  aws_account_id = local.common_vars.aws_account_id
  aws_region     = local.common_vars.aws_region
  env_name       = local.common_vars.env_name

  terraform_tags = {
    Terraform   = true
    Environment = local.common_vars.env_name
    Region      = local.aws_region
    AccountId   = local.aws_account_id
  }
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "${local.env_name}-${local.aws_account_id}-${local.aws_region}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "terraform-locks"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  disable_init = tobool(get_env("TERRAGRUNT_DISABLE_INIT", "false")) # for validate-all
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
}
EOF
}

inputs = merge(
  local.common_vars,
  {
    tags = local.terraform_tags
    region = local.aws_region
  }
)
