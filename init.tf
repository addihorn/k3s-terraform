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
  pool = "ssd"
}

resource "libvirt_volume" "centos-base-image" {
  name = "k3s-centos-base-image"
  source = "https://cloud.centos.org/centos/8-stream/x86_64/images/CentOS-Stream-GenericCloud-8-20210603.0.x86_64.qcow2"
  format = "qcow2"
  pool = "ssd"
}

resource "libvirt_volume" "ubuntu-base-image" {
  name = "k3s-ubuntu-base-image"
  source = "https://cloud-images.ubuntu.com/releases/groovy/release-20210720/ubuntu-20.10-server-cloudimg-amd64-disk-kvm.img"
  format = "qcow2"
  pool = "ssd"
}
