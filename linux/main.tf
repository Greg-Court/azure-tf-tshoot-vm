provider "azurerm" {
  features {}
  subscription_id = local.subscription_id
}

locals {
  common_tags = {
    "Purpose"    = "Troubleshooting"
    "Temporary"  = "True"
    "DeployedOn" = formatdate("YYYY-MM-DD", timestamp())
    "DeployedBy" = "Cloud Direct"
  }

  # Extract subscription_id and resource group from subnet_id using regex
  subscription_id = element(regex("/subscriptions/([^/]+)/", var.subnet_id), 0)
  subnet_resource_group = element(regex("/resourceGroups/([^/]+)/", var.subnet_id), 0)
  vnet_name = element(regex("/virtualNetworks/([^/]+)/", var.subnet_id), 0)
  subnet_name = element(regex("/subnets/([^/]+)", var.subnet_id), 0)
  
  # Generate VM name based on location from the resource group
  vm_name = "vm-tshoot-${data.azurerm_resource_group.subnet_rg.location}"
  
  vm_tags_merged = merge(local.common_tags, var.vm_tags)
  rg_tags_merged = merge(local.common_tags, var.rg_tags)
}

# Get subnet data
data "azurerm_subnet" "this" {
  name                 = local.subnet_name
  virtual_network_name = local.vnet_name
  resource_group_name  = local.subnet_resource_group
}

# Get resource group that contains the subnet to extract location
data "azurerm_resource_group" "subnet_rg" {
  name = local.subnet_resource_group
}

# Create resource group
resource "azurerm_resource_group" "this" {
  name     = "rg-${local.vm_name}"
  location = data.azurerm_resource_group.subnet_rg.location
  tags     = local.rg_tags_merged
}

# Create network interface
resource "azurerm_network_interface" "this" {
  name                = "${local.vm_name}-nic"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create Linux VM
resource "azurerm_linux_virtual_machine" "this" {
  name                                                   = local.vm_name
  resource_group_name                                    = azurerm_resource_group.this.name
  location                                               = azurerm_resource_group.this.location
  size                                                   = "Standard_B1s"
  admin_username                                         = "azureadmin"
  admin_password                                         = var.admin_password
  disable_password_authentication                        = false
  network_interface_ids                                  = [azurerm_network_interface.this.id]
  vm_agent_platform_updates_enabled                      = true
  patch_mode                                             = "AutomaticByPlatform"
  bypass_platform_safety_checks_on_user_schedule_enabled = true
  secure_boot_enabled                                    = false
  tags                                                   = local.vm_tags_merged

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}