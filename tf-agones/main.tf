data "local_file" "kubeconfig" {
  filename = "${path.root}/../kubeconfig-minikube.yaml"
}

# create the gameservers NS for agones
resource "kubernetes_namespace" "gameservers-ns" {
  lifecycle {
    ignore_changes = [metadata]
  }

  metadata {
    name = "gameservers"
    labels = {
      role = "gameservers"
    }
  }
}

# Agones services require an LB to work, so add the config map for metallb
# Have to use the helm chart because enabling the addon causes issues by overwriting configs, even if they exist beforehand

# Mostly we take defaults, but good to call them out in any case
resource "helm_release" "metallb-helm" {

  name       = "metallb"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "metallb"
  version    = "2.6.1"
  namespace  = kubernetes_namespace.metallb-ns.metadata.0.name
  set {
    name  = "existingConfigMap"
    value = kubernetes_config_map.metallb-config.metadata.0.name
  }

}
# Would be nice to find a way to configure this successfully with default to avoid the need to specify the address ranges here
resource "kubernetes_config_map" "metallb-config" {
  metadata {
    name      = "config"
    namespace = kubernetes_namespace.metallb-ns.metadata.0.name
  }
  data = {
    #TODO: figure out a way to abstract this out
    config = <<EOF
address-pools:
- name: default
  protocol: layer2
  addresses:
  - 192.168.2.225-192.168.2.250
    EOF
  }
}

resource "kubernetes_namespace" "metallb-ns" {
  metadata {
    name = "metallb-system"
    labels = {
      app = "metallb"
    }
  }
}
# need a service account to get a token for the agones helm install
resource "kubernetes_service_account" "gs-admin-sa" {
  metadata {
    name      = "gs-admin"
    namespace = "kube-system"
  }
}
# give the service account admin permissions on the cluster so we can do what we like
resource "kubernetes_cluster_role_binding" "minikube-admin-bind" {
  metadata {
    name = "minikube-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.gs-admin-sa.metadata[0].name
    namespace = "kube-system"
  }
}

# Get the service account token for the new account, will be used in the agones helm release
data "kubernetes_secret" "admin-sa-secret" {
  metadata {
    namespace = "kube-system"
    name      = kubernetes_service_account.gs-admin-sa.default_secret_name
  }
}

# finally, we get around to installing agones itself - I would love to add a depends_on block here so that it deployed last but not allowed at the moment
# metallb comes up fast enough that it will deploy as long as there are no issues
module "helm_agones" {
  source = "git::https://github.com/googleforgames/agones.git//install/terraform/modules/helm3/?ref=main"

  udp_expose             = "false"
  agones_version         = var.agones_version
  force_update           = false
  values_file            = ""
  chart                  = "agones"
  feature_gates          = var.feature_gates
  host                   = yamldecode(data.local_file.kubeconfig.content)["clusters"][0]["cluster"]["server"]
  token                  = lookup(data.kubernetes_secret.admin-sa-secret.data, "token")
  cluster_ca_certificate = base64decode(yamldecode(data.local_file.kubeconfig.content)["clusters"][0]["cluster"]["certificate-authority-data"])
  log_level              = var.log_level
  gameserver_minPort     = 7000
  gameserver_maxPort     = 7100
  gameserver_namespaces  = ["default", "gameservers"]
}
