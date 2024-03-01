output "droplet_name" {
  value = digitalocean_droplet.web.name
}

output "droplet_ipv4_address" {
  value = digitalocean_droplet.web.ipv4_address
}