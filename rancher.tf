
resource "null_resource" "install-rancher" {

  # this should run at the very end, when the k3s-cluster is up
  depends_on = [
    null_resource.migrate-calico
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
