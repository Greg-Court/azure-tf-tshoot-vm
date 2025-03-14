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

  # Extract subscription_id from subnet_id using regex
  subscription_id = element(regex("/subscriptions/([^/]+)/", var.subnet_id), 0)

  vm_tags_merged = merge(local.common_tags, var.vm_tags)
  rg_tags_merged = merge(local.common_tags, var.rg_tags)
}

# Create resource group
resource "azurerm_resource_group" "this" {
  name     = "rg-${var.vm_name}"
  location = var.location
  tags     = local.rg_tags_merged
}

# Create network interface
resource "azurerm_network_interface" "this" {
  name                = "${var.vm_name}-nic"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create Linux VM if os_type is 'linux'
resource "azurerm_linux_virtual_machine" "this" {
  count                                                  = lower(var.os_type) == "linux" ? 1 : 0
  name                                                   = var.vm_name
  resource_group_name                                    = azurerm_resource_group.this.name
  location                                               = azurerm_resource_group.this.location
  size                                                   = "Standard_B1s"
  admin_username                                         = "azureadmin"
  admin_password                                         = "yeBoi9000!"
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
    sku       = "24_04-lts-gen2"
    version   = "latest"
  }
}

# Create Windows VM if os_type is 'windows'
resource "azurerm_windows_virtual_machine" "this" {
  count                                                  = lower(var.os_type) == "windows" ? 1 : 0
  name                                                   = var.vm_name
  resource_group_name                                    = azurerm_resource_group.this.name
  location                                               = azurerm_resource_group.this.location
  size                                                   = "Standard_B2s"
  admin_username                                         = "azureadmin"
  admin_password                                         = "yeBoi9000!"
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
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}