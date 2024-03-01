resource "digitalocean_ssh_key" "my_ssh_key" {
  name       = "my_ssh_key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}
