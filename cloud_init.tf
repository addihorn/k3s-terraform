## defines and fills the cloud-init template

data "template_file" "user_data" {
  template = file("${path.root}/cloud_init.cfg")
  vars = {
    ssh-public-keys = chomp(tls_private_key.ssh.public_key_openssh)
  }
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name= "k3s-commininit.iso"
  user_data = data.template_file.user_data.rendered
}
