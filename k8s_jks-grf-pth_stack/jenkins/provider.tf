#-------------------
#   Crear Provider
#-------------------
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.21.1"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/kubeconfig.syndeno"
  config_context = "arn:aws:eks:eu-west-3:143725566489:cluster/syndeno"
}

resource "kubernetes_namespace" "tst-ns-terraform" {
  metadata {
    name = "jks-grf-pth"
  }
}