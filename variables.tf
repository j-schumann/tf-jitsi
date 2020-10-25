# Set the variable value in *.tfvars file
# or using the -var="hcloud_token=..." CLI option
variable "hcloud_token" {}

variable "acme_mail" {}

variable "users" {}

variable "public_domain" {}

variable "os_image" {
    default = "ubuntu-20.04"
}

variable "master_type" {
    default = "cpx21"
}

variable "location" {
    default = "nbg1"
}

variable "ip_range" {
    default = "10.0.0.0/24"
}
