# Azure Troubleshooting VM Terraform Module

This module deploys a Linux or Windows virtual machine for troubleshooting purposes in Azure. It's designed to be simple to use while allowing extensive customization when needed.

## Features
- Rapid deployment of either Linux or Windows VMs with minimal configuration
- Automatic tagging with deployment date and purpose
- Extracts location & network information from subnet ID
- Customizable VM properties for specific testing scenarios
- Support for static IP address assignment

## Usage

### Steps
1. Login via Azure CLI to the correct tenant (selecting the subscription is not required)
2. Run terraform init
3. Run terraform apply

### Minimal Configuration
In its most simple form, a troubleshooting VM can be deployed with just the subnet ID and OS type:

```terraform
module "tshoot_vm" {
  source    = "github.com/Greg-Court/azure-tf-tshoot-vm"
  subnet_id = "<subnet_id>"
  os_type   = "linux"  # windows or linux
}
```

### Complete Configuration Example
Here's an example showing all available customization options:

```terraform
module "tshoot_vm" {
  source    = "github.com/Greg-Court/azure-tf-tshoot-vm"
  
  # Required parameters
  subnet_id = "<subnet_id>"
  os_type   = "windows"  # windows or linux
  
  # VM configuration
  vm_name_prefix = "vm-custom"
  vm_size        = "Standard_D2s_v3"
  admin_username = "customadmin"
  admin_password = "CustomP@ssw0rd!"
  
  # OS disk configuration
  os_disk_caching              = "ReadOnly"
  os_disk_storage_account_type = "Premium_LRS"
  
  # VM image configuration
  source_image_publisher = "MicrosoftWindowsDesktop"
  source_image_offer     = "Windows-10"
  source_image_sku       = "win10-21h2-pro"
  source_image_version   = "latest"
  
  # Network configuration
  private_ip_address_allocation = "Static"
  private_ip_address            = "10.0.1.10"  # Required when allocation is Static
  
  # Security and patching
  vm_agent_platform_updates_enabled = true
  patch_mode                        = "Manual"
  bypass_platform_safety_checks     = false
  secure_boot_enabled               = true
  
  # Tags
  vm_tags = {
    Environment = "Testing"
    Backup      = "Daily"
    Owner       = "IT Support"
    PatchGroup  = "Weekly"
  }
  
  rg_tags = {
    Department = "IT"
    CostCenter = "12345"
  }
}
```

## Required Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| subnet_id | The ID of the subnet where the VM will be deployed | `string` | yes |
| os_type | The OS type for the VM. Can be 'linux' or 'windows' | `string` | yes |

## Optional Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| vm_name_prefix | Prefix for the VM name | `string` | `"vm-tshoot"` |
| vm_size | The size of the VM | `string` | `"Standard_B1s"` (Linux) or `"Standard_B2ms"` (Windows) |
| admin_username | The administrator username for the VM | `string` | `"azureadmin"` |
| admin_password | The administrator password for the VM | `string` | `"Pa$$w0rd123!"` |
| os_disk_caching | The type of caching to use on the OS disk | `string` | `"ReadWrite"` |
| os_disk_storage_account_type | The storage account type for the OS disk | `string` | `"StandardSSD_LRS"` |
| source_image_publisher | The publisher of the VM image | `string` | OS-dependent default |
| source_image_offer | The offer of the VM image | `string` | OS-dependent default |
| source_image_sku | The SKU of the VM image | `string` | OS-dependent default |
| source_image_version | The version of the VM image | `string` | `"latest"` |
| private_ip_address_allocation | The private IP address allocation method | `string` | `"Dynamic"` |
| private_ip_address | The static private IP address to assign when private_ip_address_allocation is 'Static' | `string` | `null` |
| vm_agent_platform_updates_enabled | Enable platform updates via VM agent | `bool` | `true` |
| patch_mode | The patching mode for the VM | `string` | `"AutomaticByPlatform"` |
| bypass_platform_safety_checks | Enable bypass platform safety checks on user schedule | `bool` | `true` |
| secure_boot_enabled | Enable secure boot | `bool` | `false` |
| vm_tags | A map of tags to assign to the virtual machine | `map(string)` | `{}` |
| rg_tags | A map of tags to assign to the resource group | `map(string)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| resource_group_name | The name of the created resource group |
| vm_id | The ID of the created VM |
| vm_name | The name of the created VM |
| private_ip_address | The private IP address of the VM |
| admin_username | The administrator username for the VM |
| admin_password | The administrator password for the VM (sensitive) |