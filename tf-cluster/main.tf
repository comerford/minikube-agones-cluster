# Rather than stomping on any existing config, create one in the repo
data "local_file" "kubeconfig" {
  depends_on = [
    null_resource.create_kubeconfig
  ]
  filename = local.kubeconfig_location
}

locals {
  kubeconfig_location = "${path.root}/../kubeconfig-minikube.yaml"
}
# TODO: make the command a bit more readable by breaking across lines
resource "null_resource" "minikube_cluster" {

  triggers = {
    cluster_name        = var.cluster_name
    kubeconfig_location = local.kubeconfig_location
  }

  provisioner "local-exec" {
    command     = "minikube start --kubernetes-version=${var.kubernetes_version} --profile ${self.triggers.cluster_name} --embed-certs --extra-config=apiserver.service-node-port-range=1-65535 --driver=hyperv --hyperv-use-external-switch --insecure-registry host.minikube.internal:5001"
    interpreter = ["pwsh", "-Command"]
    when        = create
  }

  provisioner "local-exec" {
    command     = "minikube delete --profile ${self.triggers.cluster_name}"
    interpreter = ["pwsh", "-Command"]
    when        = destroy
  }
}

resource "null_resource" "create_kubeconfig" {
  depends_on = [
    null_resource.minikube_cluster
  ]
  triggers = {
    cluster_name        = var.cluster_name
    kubeconfig_location = local.kubeconfig_location
  }
  provisioner "local-exec" {
    command     = "minikube kubectl -- config view --flatten > ${self.triggers.kubeconfig_location}"
    interpreter = ["pwsh", "-Command"]
    when        = create
  }
  provisioner "local-exec" {
    command     = "rm ${self.triggers.kubeconfig_location}"
    interpreter = ["pwsh", "-Command"]
    when        = destroy
  }

}
