#---------------------------------
#         Crea deployment
#---------------------------------
# Estamos creando un load_balancer, creando dos replicas de ese pod
resource "kubernetes_deployment_v1" "webapp-deploy" {
  metadata {
    name = var.name_deploy
    labels = {
      app = var.nm_lbls-app
    }
    namespace = var.namespace
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = var.nm_lbls-app
      }
    }
    template {
      metadata {
        labels = {
          app = var.nm_lbls-app
        }
      }
      spec {
        container {
          image = "kodekloud/webapp-color:v1"
          name  = "webapp-ko"
          port {
            container_port = var.puerto_contenedor #Puerto del contenedor
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
    name      = var.nm_svc
    namespace = var.namespace
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.webapp-deploy.metadata.0.labels.app
    }
    session_affinity = "ClientIP"
    port {
      port        = var.puerto_svc        #Puerto del servicio
      target_port = var.puerto_contenedor #Puerto del contenedor
    }
    type = "NodePort"
  }
}

#-------------------------------------
#       Crea un Ingress
#-------------------------------------
resource "kubernetes_ingress_v1" "webapp-ingress" {
  metadata {
    name      = var.nm_ingress
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"                 = "nginx",
      "cert-manager.io/cluster-issuer"              = "syndeno-issuer"
      "kubernetes.io/ingress.allow-http"            = "false"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "0"
    }
  }

  spec {
    rule {
      host = var.dns
      http {
        path {
          backend {
            service {
              name = var.nm_svc
              port {
                number = var.puerto_svc #Puerto del servicio
              }
            }
          }
          path = "/"
        }
      }
    }

    tls {
      hosts       = [var.dns]
      secret_name = var.dns
    }
  }
}