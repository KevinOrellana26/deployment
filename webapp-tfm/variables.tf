/*Lugar en donde creamos la variables y sus valores por defecto. Asi, unicamente cambiando estas variables podemos reutilizar este código.*/

variable "namespace" {
  description = "Nombre de la namespace a utilizar"
  default     = "tst-ns-tfm"
  type        = string
}

variable "name_deploy" {
  description = "Nombre del deployment a ejecutar"
  default     = "webapp-deploy"
  type        = string
}

variable "nm_lbls-app" {
  description = "Valor de la label app"
  default     = "webapp"
  type        = string
}

variable "nm_svc" {
  description = "Nombre del servicio a ejecutar"
  default     = "webapp-svc"
  type        = string
}

variable "nm_ingress" {
  description = "Nombre del ingress a ejecutar"
  default     = "webapp-ingress"
  type        = string
}

variable "puerto_contenedor" {
  description = "Puerto del contenedor"
  default     = 8080
  type        = number
}

variable "puerto_svc" {
  description = "Puerto del svc"
  default     = 8088
  type        = number
}

variable "dns" {
  description = "url para acceder a la web"
  default     = "webapp.plt.aw.syndeno.net"
  type        = string
}