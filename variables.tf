variable "subnet_id" {
  description = "The ID of the subnet where the VM will be deployed"
  type        = string
}

variable "os_type" {
  description = "The OS type for the VM. Can be 'linux' or 'windows'"
  type        = string
  default     = "linux"
  
  validation {
    condition     = contains(["linux", "windows"], lower(var.os_type))
    error_message = "The os_type value must be either 'linux' or 'windows'."
  }
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