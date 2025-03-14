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