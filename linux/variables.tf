variable "vm_name" {
  description = "The name of the virtual machine"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the VM will be deployed"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be deployed"
  type        = string
}

variable "vm_tags" {
  description = "A map of tags to assign to the virtual machine"
  type        = map(string)
  default     = {}
}

variable "rg_tags" {
  description = "A map of tags to assign to the resource group"
  type        = map(string)
  default     = {}
}

variable "admin_password" {
  description = "The administrator password for the VM"
  type        = string
  sensitive   = true
  default     = "Pa$$w0rd123!"
}