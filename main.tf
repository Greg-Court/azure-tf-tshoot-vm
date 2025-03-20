provider "azurerm" {
  features {}
  subscription_id = local.subscription_id
}

resource "random_integer" "id" {
  min = 100
  max = 999
}

locals {
  # Extract subscription_id and resource group from subnet_id using regex
  subscription_id = element(regex("/subscriptions/([^/]+)/", var.subnet_id), 0)
  subnet_resource_group = element(regex("/resourceGroups/([^/]+)/", var.subnet_id), 0)
  vnet_name = element(regex("/virtualNetworks/([^/]+)/", var.subnet_id), 0)
  subnet_name = element(regex("/subnets/([^/]+)", var.subnet_id), 0)
  
  # Get location from resource group
  location = data.azurerm_resource_group.subnet_rg.location

  # Try to get short region code, fall back to full location name if not found
  location_short = try(local.region_short_mappings[local.location], local.location)

  # Generate VM name based on location, using short code if available
  vm_name = "${var.vm_name_prefix}-${substr(lower(var.os_type), 0, 3)}-${local.location_short}-${random_integer.id.result}"
  
  # Determine OS type to simplify conditionals
  is_linux = lower(var.os_type) == "linux"

  # VM size defaults based on OS type - simplified approach
  default_linux_vm_size = "Standard_B2s"
  default_windows_vm_size = "Standard_B2ms"
  vm_size = var.vm_size != "" ? var.vm_size : (local.is_linux ? local.default_linux_vm_size : local.default_windows_vm_size)
  
  # Source image reference defaults based on OS type - simplified approach
  default_linux_publisher = "canonical"
  default_linux_offer = "ubuntu-24_04-lts"
  default_linux_sku = "server"
  
  default_windows_publisher = "MicrosoftWindowsServer"
  default_windows_offer = "WindowsServer"
  default_windows_sku = "2022-Datacenter"
  
  source_image_publisher = var.source_image_publisher != null ? var.source_image_publisher : (local.is_linux ? local.default_linux_publisher : local.default_windows_publisher)
  source_image_offer = var.source_image_offer != null ? var.source_image_offer : (local.is_linux ? local.default_linux_offer : local.default_windows_offer)
  source_image_sku = var.source_image_sku != null ? var.source_image_sku : (local.is_linux ? local.default_linux_sku : local.default_windows_sku)
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
  location = local.location
  tags     = var.rg_tags
}

# Create network interface
resource "azurerm_network_interface" "this" {
  name                = "${local.vm_name}-nic"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_address_allocation
    private_ip_address            = var.private_ip_address_allocation == "Static" ? var.private_ip_address : null
  }
}

locals {
  # Region name to short code mappings
  region_short_mappings = {
    "East Asia" = "ea"
    "West US" = "wus"
    "East US" = "eus"
    "Central US" = "cus"
    "East US 2" = "eus2"
    "North Central US" = "ncus"
    "South Central US" = "scus"
    "North Europe" = "ne"
    "West Europe" = "we"
    "Southeast Asia" = "sea"
    "Japan East" = "jpe"
    "Japan West" = "jpw"
    "Brazil South" = "brs"
    "Australia East" = "ae"
    "Australia Southeast" = "ase"
    "Central India" = "inc"
    "South India" = "ins"
    "Canada Central" = "cnc"
    "Canada East" = "cne"
    "West Central US" = "wcus"
    "West US 2" = "wus2"
    "UK West" = "ukw"
    "UK South" = "uks"
    "Central US EUAP" = "ccy"
    "East US 2 EUAP" = "ecy"
    "Korea South" = "krs"
    "Korea Central" = "krc"
    "France Central" = "frc"
    "France South" = "frs"
    "Australia Central" = "acl"
    "Australia Central 2" = "acl2"
    "UAE Central" = "uac"
    "UAE North" = "uan"
    "South Africa North" = "san"
    "South Africa West" = "saw"
    "West India" = "inw"
    "Norway East" = "nwe"
    "Norway West" = "nww"
    "Switzerland North" = "szn"
    "Switzerland West" = "szw"
    "Germany North" = "gn"
    "Germany West Central" = "gwc"
    "Sweden Central" = "sdc"
    "Sweden South" = "sds"
    "Brazil Southeast" = "bse"
    "West US 3" = "wus3"
    "Jio India Central" = "jic"
    "Jio India West" = "jiw"
    "Qatar Central" = "qac"
    "Poland Central" = "plc"
    "Malaysia South" = "mys"
    "Taiwan North" = "twn"
    "Taiwan Northwest" = "tnw"
    "Israel Central" = "ilc"
    "Italy North" = "itn"
    "Mexico Central" = "mxc"
    "Spain Central" = "spc"
    "Chile Central" = "clc"
    "New Zealand North" = "nzn"
    "Malaysia West" = "myw"
    "Indonesia Central" = "idc"
    "Southeast US" = "use"
    "USGov Virginia" = "ugv"
    "USGov Arizona" = "uga"
    "USGov Texas" = "ugt"
    "USDoD Central" = "udc"
    "USDoD East" = "ude"
    "China North" = "bjb"
    "China East" = "sha"
    "China North 2" = "bjb2"
    "China East 2" = "sha2"
    "China North 3" = "bjb3"
    "China East 3" = "sha3"
  }
}