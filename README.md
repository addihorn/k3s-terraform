# k3s-terraform

Terraform and cloud-init files to deploy a non-customized K3s-Cluster with 1 master and 3 worker nodes on libvirt.
Please be advised that this is a private proof of concept and still needs a lot of flexibility-enhancements (variables etc.)

## Install Libvirt provider
Install TF-Libvirt provider as described in https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/README.md
(please see https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/docs/migration-13.md if your are using Terraform 13 or higher)

## Run with
```bash
$ terraform plan

$ terraform apply
```
