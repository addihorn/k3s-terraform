# k3s-terraform

Terraform and cloud-init files to deploy a non-customized K3s-Cluster with 1 master and 3 worker nodes on libvirt.
Please be advised that this is a private proof of concept and still needs a lot of flexibility-enhancements (variables etc.)

## Prerequisites
- ansible installed
- terraform libvirt provider installed (see below)
- terraform ansible provisioner installed (see https://github.com/radekg/terraform-provisioner-ansible#local-installation)


## Install Libvirt provider
Install TF-Libvirt provider as described in https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/README.md
(please see https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/docs/migration-13.md if your are using Terraform 13 or higher)

## Run with

Variables can be defined in file ```terraform.tfvars```  

```bash
$ terraform init
$ terraform validate

$ terraform plan  

$ terraform apply
```
