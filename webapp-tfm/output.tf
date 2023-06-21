output "dns_pública" {
  description = "DNS pública de la página web"
  value       = "https://${kubernetes_ingress_v1.webapp-ingress.spec[0].rule[0].host}"
}

# output "pod_names" {
#   description = "muestra el nombre de los pods creados"
#   value       = kubernetes_deployment_v1.webapp-deploy.spec[0].template[0].metadata[0].labels.app
# }

