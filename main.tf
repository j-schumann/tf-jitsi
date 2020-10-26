provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_ssh_key" "root" {
  name = "devops"
  public_key = file("${path.module}/ssh/key.pub")
}

# Network Setup
resource "hcloud_network" "network" {
  name     = "network-1"
  ip_range = var.ip_range
}

resource "hcloud_network_subnet" "subnet" {
  network_id   = hcloud_network.network.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = var.ip_range
}

# Master Setup
resource "hcloud_server" "master" {
  name        = "jitsimaster"
  image       = var.os_image
  server_type = var.master_type
  location    = var.location
  user_data   = templatefile("${path.module}/user-data/master.tpl", {
    ip_range       = var.ip_range
    ssh_public_key = hcloud_ssh_key.root.public_key
    public_domain  = var.public_domain
    public_ip      = hcloud_floating_ip.public_ip.ip_address
    acme_mail      = var.acme_mail
    users          = var.users
  })
  ssh_keys    = [ hcloud_ssh_key.root.id ]
}

resource "hcloud_server_network" "master_network" {
  server_id = hcloud_server.master.id
  subnet_id = hcloud_network_subnet.subnet.id
}

resource "hcloud_floating_ip" "public_ip" {
  type          = "ipv4"
  name          = "public-ip"
  home_location = var.location
}

resource "hcloud_floating_ip_assignment" "master_floating_ip" {
  floating_ip_id = hcloud_floating_ip.public_ip.id
  server_id      = hcloud_server.master.id
}

output "public_ipv4" {
  description = "Public IP address"
  value = hcloud_floating_ip.public_ip.ip_address
}

