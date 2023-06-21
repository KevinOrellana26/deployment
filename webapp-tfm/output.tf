output "dns_pública" {
  description = "DNS pública de la página web"
  value       = "https://${kubernetes_ingress_v1.webapp-ingress.spec[0].rule[0].host}"
}