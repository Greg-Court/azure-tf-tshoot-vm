resource "azurerm_windows_virtual_machine" "this" {
  count                                                  = lower(var.os_type) == "windows" ? 1 : 0
  name                                                   = local.vm_name
  resource_group_name                                    = azurerm_resource_group.this.name
  location                                               = azurerm_resource_group.this.location
  size                                                   = "Standard_B1s"
  admin_username                                         = "azureadmin"
  admin_password                                         = var.admin_password
  network_interface_ids                                  = [azurerm_network_interface.this.id]
  patch_mode                                             = "AutomaticByPlatform"
  vm_agent_platform_updates_enabled                      = true
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