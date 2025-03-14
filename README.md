Azure terraform module that deploys a linux or windows virtual machine.

In its most simple form, a virtual machine can be deployed via a module call like so:

module "tshoot_vm" {
  source    = "github.com/Greg-Court/azure-tf-tshoot-vm"
  subnet_id = "<subnet_id>"
  os_type   = "linux"  # windows or linux
  vm_tags = {
    Backup     = "Manual"
    PatchGroup = "Manual"
  }
  rg_tags = {}
}

Customisations available are as follows:

