## creates a tls key pair to access the VMs via ssh

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits = "4096"
}

resource "local_file" "private_key" {
  content = tls_private_key.ssh.private_key_pem
  filename = "ssh-privat-key.pem"
  file_permission = "0600"
}
