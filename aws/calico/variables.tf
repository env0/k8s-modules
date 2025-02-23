variable "calico_docker_hub_credentials" {
    description = "Docker Hub credentials"
    type = object({
        username = string
        password = string
        email    = string
    })
    default = null
    sensitive = true
}
