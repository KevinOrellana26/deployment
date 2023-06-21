#---------------------------
#     Ingress
#---------------------------
resource "kubernetes_ingress_v1" "example_ingress" {
  metadata {
    name = "example-ingress"
    namespace = "tst-ns-tfm"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx",
      "cert-manager.io/cluster-issuer" = "syndeno-issuer"
      "kubernetes.io/ingress.allow-http" = "false"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "0"
    }
  }

  spec {
    # backend {
    #   service_name = "${var.deployment_name}-np"
    #   service_port = 80
    # }
    rule {
      host = "nginx.plt.aw.syndeno.net"
      http {
        path {
          backend {
            service {
              name = "myapp-1"
              port {
                number = 8080
              }
            }
          }
          path = "/"
        }
      }
    }

    tls {
      hosts = ["nginx.plt.aw.syndeno.net"]
      secret_name = "nginx.plt.aw.syndeno.net"
    }
  }
}


#--------------------------------------
#         Service
#--------------------------------------

resource "kubernetes_service_v1" "example" {
  metadata {
    name = "myapp-1"
    namespace = "tst-ns-tfm"
  }
  spec {
    selector = {
      app = kubernetes_pod.example.metadata.0.labels.app
    }
    session_affinity = "ClientIP"
    port {
      port        = 8080
      target_port = 80
    }
    type = "NodePort"
  }
}

# resource "kubernetes_service_v1" "example2" {
#   metadata {
#     name = "myapp-2"
#     namespace = "tst-ns-tfm"
#   }
#   spec {
#     selector = {
#       app = kubernetes_pod.example2.metadata.0.labels.app
#     }
#     session_affinity = "ClientIP"
#     port {
#       port        = 8081
#       target_port = 80
#     }
#     type = "NodePort"
#   }
# }

#---------------------------------------------
#           Pod
#---------------------------------------------
resource "kubernetes_pod" "example" {
  metadata {
    name = "terraform-example"
    labels = {
      app = "myapp-1"
    }
    namespace = "tst-ns-tfm"
  }
  spec {
    container {
      image = "nginx:latest"
      name  = "example"
      port {
        container_port = 8080
      }
    }
  }
}

# resource "kubernetes_pod" "example2" {
#   metadata {
#     name = "terraform-example2"
#     labels = {
#       app = "myapp-2"
#     }
#     namespace = "tst-ns-tfm"
#   }
#   spec {
#     container {
#       image = "nginx:latest"
#       name  = "example"
#       port {
#         container_port = 8081
#       }
#     }
#   }
# }


