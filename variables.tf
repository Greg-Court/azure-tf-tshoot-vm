variable "vm_name" {
  description = "The name of the virtual machine"
  type        = string
}

variable "subscription_id" {
  description = "The ID of the Azure Subscription where resources will be deployed"
  type        = string
}

variable "os_type" {
  description = "The OS type of the VM. Valid values are 'windows' or 'linux'"
  type        = string
  validation {
    condition     = contains(["windows", "linux"], lower(var.os_type))
    error_message = "Valid values for os_type are 'windows' or 'linux'."
  }
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