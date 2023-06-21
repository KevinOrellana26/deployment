# Este archivo se utiliza para que luego Terraform sepa donde conectarse
terraform {
  required_providers {
    docker = {
        source = "kreuzwerker/docker"
        version = "3.0.2"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}