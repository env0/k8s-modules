variable "calico_docker_hub_credentials" {
  description = "Deprecated and ignored. Calico v3.33 pulls its images from quay.io, so it needs no Docker Hub credentials"
  type = object({
    username = string
    password = string
    email    = string
  })
  default   = null
  sensitive = true
}
