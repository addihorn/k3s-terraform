
variable "node_centos_count" {
  type = number
  default = 1
}

resource "libvirt_volume" "centos-node-disk" {
  count = var.node_centos_count
  name = "centos-node-${count.index +1}"
  pool = "ssd"
  format = "qcow2"
  base_volume_id = libvirt_volume.centos-base-image.id
}


# Create Host for Master
# Define KVM domain to create
resource "libvirt_domain" "centos-node" {
  count  = var.node_centos_count
  name   = "centos-node-${count.index + 1}"
  memory = "10000"
  vcpu   = 2
 
  network_interface {
    network_name = "default"
    addresses = ["192.168.122.${count.index + 21}"]
    wait_for_lease = true
  }
 
  disk {
    volume_id = libvirt_volume.centos-node-disk[count.index].id
  }
 
  cloudinit = libvirt_cloudinit_disk.commoninit.id
 
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
 
  provisioner "ansible" {
    connection {
      type = "ssh"
      user = "install-user"
      private_key = tls_private_key.ssh.private_key_pem
      host = self.network_interface.0.addresses.0
    }
    plays {
      playbook {
        file_path = "${path.root}/provisioning/k3s-cluster.yaml"
      }
      hosts = []
      groups = ["k3s_nodes"]
      extra_vars = {
        k3s_token = "${var.k3s_agent_token}"
        k3s_version ="${var.k3s_version}" 
        k3s_cluster_controller = "${libvirt_domain.kube-master.0.network_interface.0.addresses.0}"
      }
    }
    ansible_ssh_settings {
      connect_timeout_seconds = 10
      connection_attempts = 10
      ssh_keyscan_timeout = 300
#      insecure_no_strict_host_key_checking = true
    }
  }
}


output "CentOS-Node-IPs" {
  value = libvirt_domain.centos-node.*.network_interface.0.addresses.0
}
