
resource "null_resource" "migrate-calico" {

  # this should run at the very end, when the k3s-cluster is up
  depends_on = [
    libvirt_domain.kube-master,
    libvirt_domain.centos-node,
    libvirt_domain.ubuntu-node,    
    libvirt_domain.kube-storage-node
  ]

  provisioner "ansible" {
    plays {
      playbook {
        file_path = "${path.root}/provisioning/calico-migration.yaml"
      }
      inventory_file = "${path.root}/provisioning/empty_inventory"
    }
  }
}
