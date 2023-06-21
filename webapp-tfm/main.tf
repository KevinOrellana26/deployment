#---------------------------------
#         Crea deployment
#---------------------------------
# Estamos creando un balanceador de carga creando dos replicas
resource "kubernetes_deployment_v1" "webapp-deploy" {
  metadata {
    name = "webapp-deploy"
    labels = {
      app = "webapp"
    }
    namespace = "tst-ns-tfm"
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "webapp"
      }
    }
    template {
      metadata {
        labels = {
          app = "webapp"
        }
      }
      spec {
        container {
          image = "kodekloud/webapp-color:v1"
          name  = "webapp-ko"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

#-----------------------------------
#         Crea un service
#-----------------------------------
resource "kubernetes_service_v1" "webapp-svc" {
  metadata {
    name = "webapp-svc"
    namespace = "tst-ns-tfm"
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.webapp-deploy.metadata.0.labels.app
    }
    session_affinity = "ClientIP"
    port {
      port        = 8088
      target_port = 8080
    }
    type = "NodePort"
  }
}

#-------------------------------------
#       Crea un ingress
#-------------------------------------
resource "kubernetes_ingress_v1" "webapp-ingress" {
  metadata {
    name = "webapp-ingress"
    namespace = "tst-ns-tfm"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx",
      "cert-manager.io/cluster-issuer" = "syndeno-issuer"
      "kubernetes.io/ingress.allow-http" = "false"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "0"
    }
  }
  
  spec {
    rule {
      host = "webapp.plt.aw.syndeno.net"
      http {
        path {
          backend {
            service {
              name = "webapp-svc"
              port {
                number = 8088
              }
            }
          }
          path = "/"
        }
      }
    }

    tls {
     hosts = ["webapp.plt.aw.syndeno.net"]
     secret_name = "webapp.plt.aw.syndeno.net"
    }
  }
}