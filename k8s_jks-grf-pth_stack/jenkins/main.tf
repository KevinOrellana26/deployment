#------------------------
#       Ingress
#------------------------
resource "kubernetes_ingress_v1" "jks-ingress" {
  metadata {
    name      = "jks-ingress"
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
      host = "jks.plt.aw.syndeno.net"
      http {
        path {
          backend {
            service {
              name = "jks-service"
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
      hosts       = ["jks.plt.aw.syndeno.net"]
      secret_name = "jks.plt.aw.syndeno.net"
    }
  }
}

#----------------------------
#           Service
#----------------------------

resource "kubernetes_service_v1" "jks-service" {
  metadata {
    name      = "jks-service"
    namespace = "jks-grf-pth"
  }
  spec {
    selector = {
      app = "jks"
    }
    session_affinity = "ClientIP"
    port {
      port        = 8080
      target_port = 8080
      protocol    = "TCP"
    }
    type = "NodePort"
  }
}

#-----------------------------
#       Deployment
#-----------------------------

resource "kubernetes_deployment_v1" "jks-deploy" {
  metadata {
    name      = "jks-deploy"
    namespace = "jks-grf-pth"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "jks"
      }
    }
    template {
      metadata {
        labels = {
          app = "jks"
        }
      }
      spec {
        container {
          image = "jenkins/jenkins:latest"
          name  = "jenkins"
          port {
            container_port = 8080
          }
          volume_mount {
            name       = "jenkins-home"
            mount_path = "/var/jenkins_home"
          }
        }
        volume {
          name = "jenkins-home"
          empty_dir {}
        }
      }
    }
  }
}