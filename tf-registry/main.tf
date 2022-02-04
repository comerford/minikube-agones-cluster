resource "kubernetes_config_map" "registry-config" {
  metadata {
    name      = "local-registry-hosting"
    namespace = "kube-public"
  }

  data = {
    "localRegistryHosting.v1" = <<-EOF
      host = "localhost:${var.registry_port}"
      help = "https://local.sigs.k8s.io/docs/user/local-registry/"
    EOF
  }
}

resource "null_resource" "start_local_registry" {

  provisioner "local-exec" {
    command     = "${path.root}\\scripts\\start-registry.ps1 ${var.registry_name} ${var.registry_port}"
    interpreter = ["pwsh", "-Command"]
    when        = create
  }

  provisioner "local-exec" {
    command     = "docker stop local-registry; docker rm local-registry"
    interpreter = ["pwsh", "-Command"]
    when        = destroy
  }

}
