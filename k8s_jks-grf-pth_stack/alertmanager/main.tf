#------------------------
#       Ingress
#------------------------
resource "kubernetes_ingress_v1" "alert-ingress" {
  metadata {
    name      = "alert-ingress"
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
      host = "alertmanager.plt.aw.syndeno.net"
      http {
        path {
          backend {
            service {
              name = "alert-service"
              port {
                number = 9093
              }
            }
          }
          path = "/"
        }
      }
    }
    tls {
      hosts       = ["alertmanager.plt.aw.syndeno.net"]
      secret_name = "alertmanager.plt.aw.syndeno.net"
    }
  }
}

#----------------------------
#           Service
#----------------------------

resource "kubernetes_service_v1" "alert-service" {
  metadata {
    name      = "alert-service"
    namespace = "jks-grf-pth"
  }
  spec {
    selector = {
      app = "alert"
    }
    session_affinity = "ClientIP"
    port {
      port        = 9093
      target_port = 9093
      protocol    = "TCP"
    }
    type = "NodePort"
  }
}

#-----------------------------
#       ConfigMap
#-----------------------------
resource "kubernetes_config_map_v1" "alert-config" {
  metadata {
    name = "alert-config"
    namespace = "jks-grf-pth"
  }
  data = {
    "alertmanager.yml" = <<EOF
  global:
    resolve_timeout: 5m
    slack_api_url: 'https://hooks.slack.com/services/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'

  route:
    group_by: ['alertname','client']
    group_wait: 10s
    group_interval: 10s
    repeat_interval: 3h
    receiver: 'slack_email_notifications'

    routes:
    - receiver: 'slack_email_notifications'
      repeat_interval: 1d
      match:
        severity: 'warning'

  receivers:
  - name: 'slack_email_notifications'
    slack_configs:
    - channel: '#alerts'
      icon_url: 'https://avatars3.githubusercontent.com/u/3380462'
      send_resolved: true
      title: |-
        [{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}] {{ .CommonLabels.alertname }} for {{ .CommonLabels.job }}
        {{- if gt (len .CommonLabels) (len .GroupLabels) -}}
          {{" "}}(
          {{- with .CommonLabels.Remove .GroupLabels.Names }}
            {{- range $index, $label := .SortedPairs -}}
              {{ if $index }}, {{ end }}
              {{- $label.Name }}="{{ $label.Value -}}"
            {{- end }}
          {{- end -}}
          )
        {{- end }}
      text: >-
        {{ range .Alerts -}}
        *Alert:* {{ .Annotations.title }}{{ if .Labels.severity }} - `{{ .Labels.severity }}`{{ end }}

        *Description:* {{ .Annotations.description }}

        *Details:*
          {{ range .Labels.SortedPairs }} • *{{ .Name }}:* `{{ .Value }}`
          {{ end }}
        {{ end }}

    email_configs:
    - to: 'alerts@syndeno.com'
      from: 'alert@syndeno.net'
      smarthost: mx.syndeno.net:587
      auth_username: 'alert@syndeno.net'
      auth_identity: 'alert@syndeno.net'
      auth_password: 'alert2022!' 
      send_resolved: true

  # - name: 'null'    

  # inhibit_rules:
  #  - source_match:
  #      severity: 'critical'
  #    equal: ['alertname', 'dev', 'instance']
  EOF
  }
}

#-----------------------------
#       Deployment
#-----------------------------

resource "kubernetes_deployment_v1" "alert-deploy" {
  metadata {
    name      = "alert-deploy"
    namespace = "jks-grf-pth"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "alert"
      }
    }
    template {
      metadata {
        labels = {
          app = "alert"
        }
      }
      spec {
        container {
          image = "prom/alertmanager:latest"
          name  = "alertmanager"
          port {
            container_port = 9093
          }
          volume_mount {
            name       = "alertmanager-data"
            mount_path = "/alertmanager"
          }
          volume_mount {
            name       = "alertmanager-file"
            mount_path = "/etc/alertmanager"
            read_only = true
          }
        }
        volume {
          name = "alertmanager-data"
          empty_dir {}
        }
        volume {
          name = "alertmanager-file"
          config_map {
            name = kubernetes_config_map_v1.alert-config.metadata.0.name
          }
        }
      }
    }
  }
}

