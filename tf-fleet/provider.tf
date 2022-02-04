provider "kubernetes" {
  config_path = data.local_file.kubeconfig.filename
}
