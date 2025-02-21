variable "calico_image_pull_secret" {
    description = "The image pull secret for Calico"
    default = null
    type = map(string)
}
