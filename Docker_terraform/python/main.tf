resource "docker_image" "python" {
  name = "python-test:latest"
}

# Create a container
resource "docker_container" "python-test" {
  image = docker_image.python.image_id
  name  = "python-test"

  restart = "always" /* como solo se muestra un mensaje hice que el contenedor se reiniciara cada vez que muestra ese mensaje desde la terminal*/
}