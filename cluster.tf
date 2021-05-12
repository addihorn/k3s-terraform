#provider "libvirt" {
#  uri = "qemu:///system"
#}

provider "libvirt" {
  uri   = "qemu+ssh://vm-user@192.168.192.41/system"
}

variable "k3s-agent-token" {
  type = string
  default = "297ecb1fadfe54d955795f75c105fee8"
}

variable "k3s-agent-count" {
  type = number
  default = 4
}

data "template_file" "user_data" {
        template = file("${path.module}/cloud_init.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  count = var.k3s-agent-count + 1
  name= "commininit-${count.index}.iso"
  user_data = data.template_file.user_data.rendered
}


resource "libvirt_volume" "k3s-master-disk" {
  name = "kube-master"
  pool = "ssd"
  source = "https://cloud.centos.org/centos/8-stream/x86_64/images/CentOS-Stream-GenericCloud-8-20201217.0.x86_64.qcow2"
  #source = "./CentOS-7-x86_64-GenericCloud.qcow2"
  format = "qcow2"
}

# Create Host for Master
# Define KVM domain to create
resource "libvirt_domain" "kube-master" {
  name   = "kube-master"
  memory = "2096"
  vcpu   = 1

  network_interface {
    network_name = "default"
    addresses = ["192.168.122.101"]
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.k3s-master-disk.id
  }

  cloudinit = libvirt_cloudinit_disk.commoninit[0].id

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "vnc"
    listen_type = "address"
    autoport = true
  }

  provisioner "remote-exec" {
    inline = [
        "sudo yum clean packages",
        "curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE=644 K3S_TOKEN=${var.k3s-agent-token} sh -"
    ]
    connection {
        type = "ssh"
        user = "install-user"
        private_key = file("${path.module}/id_rsa")
        host = self.network_interface.0.addresses.0
    }
  }  
}


resource "libvirt_volume" "k3s-node-disk" { 
  count = var.k3s-agent-count
  name = "kube-node-${count.index +1}"
  pool = "ssd"
  source = "https://cloud.centos.org/centos/8-stream/x86_64/images/CentOS-Stream-GenericCloud-8-20201217.0.x86_64.qcow2"
  #source = "./CentOS-7-x86_64-GenericCloud.qcow2"
  format = "qcow2"
}


resource "libvirt_domain" "kube-nodes" {
  count = var.k3s-agent-count
  name = "kube-node-${count.index +1}"
  memory = 10000
  vcpu = 2

  network_interface {
    network_name = "default"
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.k3s-node-disk[count.index].id
  }

  cloudinit = libvirt_cloudinit_disk.commoninit[count.index + 1].id

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "vnc"
    listen_type = "address"
    autoport = true
  }

  provisioner "remote-exec" {
    inline = [
	"sudo yum clean packages",
	"curl -sfL https://get.k3s.io | K3S_URL=https://${libvirt_domain.kube-master.network_interface.0.addresses.0}:6443 K3S_TOKEN=${var.k3s-agent-token} K3S_NODE_NAME=${self.name} sh -"
    ]
    connection {
	type = "ssh"
	user = "install-user"
        private_key = file("${path.module}/id_rsa")
        host = self.network_interface.0.addresses.0
    }
  }
}



output "master-ip" {
  value = libvirt_domain.kube-master.network_interface.0.addresses.0
}

output "node-ips" {
  value =  libvirt_domain.kube-nodes.*.network_interface.0.addresses.0
}
