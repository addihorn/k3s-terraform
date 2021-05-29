
resource "null_resource" "install-rancher" {

  # this should run at the very end, when the k3s-cluster is up
  depends_on = [
    libvirt_domain.kube-master,
    libvirt_domain.kube-node,
    libvirt_domain.kube-storage-node
  ]

  provisioner "ansible" {
    plays {
      playbook {
        file_path = "${path.root}/provisioning/rancher.yaml"
      }
      inventory_file = "${path.root}/provisioning/empty_inventory"
    }
  }
}
