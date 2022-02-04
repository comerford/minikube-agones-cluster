provider "kubernetes" {
  config_path = data.local_file.kubeconfig.filename
  #config_context = "kind-${var.cluster_name}"
}

provider "helm" {
  kubernetes {
    config_path = data.local_file.kubeconfig.filename
  }
}
