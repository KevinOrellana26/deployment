#------------------------
#       Ingress
#------------------------
resource "kubernetes_ingress_v1" "pth-ingress" {
  metadata {
    name      = "pth-ingress"
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
      host = "prometheus.plt.aw.syndeno.net"
      http {
        path {
          backend {
            service {
              name = "pth-service"
              port {
                number = 9090
              }
            }
          }
          path = "/"
        }
      }
    }
    tls {
      hosts       = ["prometheus.plt.aw.syndeno.net"]
      secret_name = "prometheus.plt.aw.syndeno.net"
    }
  }
}

#----------------------------
#           Service
#----------------------------

resource "kubernetes_service_v1" "pth-service" {
  metadata {
    name      = "pth-service"
    namespace = "jks-grf-pth"
  }
  spec {
    selector = {
      app = "pth"
    }
    session_affinity = "ClientIP"
    port {
      port        = 9090
      target_port = 9090
      protocol    = "TCP"
    }
    type = "NodePort"
  }
}


resource "kubernetes_config_map_v1" "prometheus-config" {
  metadata {
    name = "prometheus-config"
    namespace = "jks-grf-pth"
  }
  data = {
    "prometheus.yml" = <<EOF
  global:
    scrape_interval: 10s
  
  rule_files:
    - "prometheus_rules.yml"
    - "kubernetes_rules.yml"

  alerting:
    alertmanagers:
    - static_configs:
        - targets:
            - "alert-service.jks-grf-pth.svc.cluster.local:9093"

  scrape_configs:
    - job_name: dc_prometheus
      honor_labels: true
      tls_config:
        insecure_skip_verify: true
      metrics_path: '/federate'
      params:
        'match[]':
          - '{job!=""}'
      static_configs:
        - targets: ['pth.getwonder.tech']
        - targets: ['pth.newe.es']
        - targets: ['pth.plt.bipeek.es']
        - targets: ['rgmftcv.gc.syndeno.net']
        - targets: ['pth.plt.sesamelon.com']
        - targets: ['pth.plt.gc.syndeno.net']
        - targets: ['pth.plt.prezo.info']
        - targets: ['pth.plt.growpro.syndeno.io']
        - targets: ['prometheus.plt.aw.syndeno.net']
      basic_auth:
        username: 'admin'
        password: 'Syndeno2022!'
    - job_name: 'jenkins'
      metrics_path: '/prometheus/'
      static_configs:
        - targets: ['jks.plt.aw.syndeno.net']
    - job_name: 'alertmanager'
      static_configs:
        - targets: ['alertmanager.plt.aw.syndeno.net']
    EOF
  }
}

resource "kubernetes_deployment_v1" "name" {
  metadata {
    name = "prometheus-deploy"
    namespace = "jks-grf-pth"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "pth"
      }
    }
    template {
      metadata {
        labels = {
          app = "pth"
        }
      }
      spec {
        container {
          name = "prometheus"
          image = "prom/prometheus:latest"
          args = [
            "--config.file=/etc/prometheus/prometheus.yml",
            "--storage.tsdb.path=/prometheus",
            "--web.console.libraries=/etc/prometheus/console_libraries",
            "--web.console.templates=/etc/prometheus/consoles",
            "--web.enable-lifecycle",
          ]
          port {
            container_port = 9090
          }
          volume_mount {
            mount_path = "/etc/prometheus"
            name = "prometheus-config-volume"
            read_only = true
          }
          volume_mount {
            mount_path = "/prometheus"
            name = "prometheus-data-volume"
          }
        }
        volume {
          name = "prometheus-config-volume"
          config_map {
            name = kubernetes_config_map_v1.prometheus-config.metadata.0.name
          }
        }
        volume {
          name = "prometheus-data-volume"
          empty_dir {}
        }
      }
    }
  }
}