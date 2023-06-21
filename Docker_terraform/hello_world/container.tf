resource "docker_container" "hello_world" {
  name = "cduser_hello_world"
  image = "tutum/hello-world"

  ports {
    internal = 80
    external = 8080
  }
}