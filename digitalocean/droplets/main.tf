resource "digitalocean_droplet" "web" {

  count = 2

  image  = "ubuntu-20-04-x64"
  name   = "web-${count.index + 1}"
  region = count.index == 0 ? "nyc1" : "nyc3"
  size   = "s-1vcpu-1gb"

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
    host        = self.ipv4_address
  }

  # The provisioner block executes the specified commands on the remote server
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y nginx",
      "sudo systemctl start nginx"
    ]
  }
}

