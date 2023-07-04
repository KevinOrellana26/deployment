#------------------------
#       Ingress
#------------------------
resource "kubernetes_ingress_v1" "grafana-ingress" {
  metadata {
    name      = "grafana-ingress"
    namespace = "jks-grf-pth"
    annotations = {
      "kubernetes.io/ingress.class"                 = "nginx",
      "cert-manager.io/cluster-issuer"              = "syndeno-issuer"
      "kubernetes.io/ingress.allow-http"            = "false"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "0"
    }
  }
  spec {
    rule {
      host = "gf.plt.aw.syndeno.net"
      http {
        path {
          backend {
            service {
              name = "grafana-service"
              port {
                number = 3000
              }
            }
          }
          path = "/"
        }
      }
    }
    tls {
      hosts       = ["gf.plt.aw.syndeno.net"]
      secret_name = "gf.plt.aw.syndeno.net"
    }
  }
}

#----------------------------
#           Service
#----------------------------

resource "kubernetes_service_v1" "grafana-service" {
  metadata {
    name      = "grafana-service"
    namespace = "jks-grf-pth"
  }
  spec {
    selector = {
      app = "gf"
    }
    session_affinity = "ClientIP"
    port {
      port        = 3000
      target_port = 3000
      protocol    = "TCP"
    }
    type = "NodePort"
  }
}


#-----------------------------
#       Deployment
#-----------------------------

resource "kubernetes_deployment_v1" "grafana-deploy" {
  metadata {
    name      = "grafana-deploy"
    namespace = "jks-grf-pth"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "gf"
      }
    }
    template {
      metadata {
        labels = {
          app = "gf"
        }
      }
      spec {
        container {
          image = "grafana/grafana:latest"
          name  = "grafana"
          port {
            container_port = 3000
          }
          volume_mount {
            name       = "grafana-data"
            mount_path = "/var/lib/grafana"
          }
        }
        volume {
          name = "grafana-data"
          empty_dir {}
        }
      }
    }
  }
}