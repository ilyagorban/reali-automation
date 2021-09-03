terraform {
  required_version = ">= 0.13.1"

  required_providers {
    local      = ">= 1.4"
    random     = ">= 2.1"
    kubernetes = "~> 1.11"
  }
}
