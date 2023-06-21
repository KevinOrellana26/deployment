# Pulls the image
# resource "docker_image" "nginx_image" {
#   name = "nginx:latest"
# }
/*Esto hacía que la imagen cuando hacía un <terraform destroy> me eliminaba la imagen que habia creado*/


# Create a container
resource "docker_container" "nginx" {
#  image = docker_image.nginx_image.image_id
  image = "nginx:latest"
  name  = "nginx"
    ports {
      internal = "80"
      external = "8080"
    }
}