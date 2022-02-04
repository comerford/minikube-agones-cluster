data "local_file" "kubeconfig" {
  filename = "${path.root}/../kubeconfig-minikube.yaml"
}

resource "kubernetes_manifest" "local-gs-fleet" {
  manifest = {
    "apiVersion" = "agones.dev/v1"
    "kind"       = "Fleet"
    "metadata" = {
      "name"      = "local-fleet"
      "namespace" = "gameservers"
    }
    "spec" = {
      # set initial replicas to zero, if you don't have a local image to pull
      "replicas" = 1
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "gameserver"
          }
        }
        "spec" = {
          "health" = {
            "failureThreshold"    = 5
            "initialDelaySeconds" = 10
            "periodSeconds"       = 5
          }
          "ports" = [
            {
              "containerPort" = 26000
              "name"          = "default"
            },
          ]
          "sdkServer" = {
            "logLevel" = "Info"
          }
          "template" = {
            "metadata" = {
              "labels" = {
                "role" = "gameservers"
              }
            }
            "spec" = {
              "containers" = [
                {
                  "image" = "host.minikube.internal:5001/xonotic-gameserver:latest"
                  "name"  = "agones-gs"
                },
              ]
              #hacky way to just get it to run on anything
              "nodeSelector" = {
                "kubernetes.io/os" = "linux"
              }
            }
          }
        }
      }
    }
  }
}
