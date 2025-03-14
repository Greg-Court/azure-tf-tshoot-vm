output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.this.name
}

output "vm_id" {
  description = "The ID of the VM"
  value       = azurerm_linux_virtual_machine.this.id
}

output "vm_name" {
  description = "The name of the VM"
  value       = azurerm_linux_virtual_machine.this.name
}

output "private_ip_address" {
  description = "The private IP address of the VM"
  value       = azurerm_linux_virtual_machine.this.private_ip_address
}

output "admin_username" {
  description = "The administrator username for the VM"
  value       = "azureadmin"
}

output "admin_password" {
  description = "The administrator password for the VM"
  value       = var.admin_password
  sensitive   = true
}