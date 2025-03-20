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
  default_windows_vm_size = "Standard_B4s"
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
 "eastasia" = "ea"
    "westus" = "wus"
    "eastus" = "eus"
    "centralus" = "cus"
    "eastus2" = "eus2"
    "northcentralus" = "ncus"
    "southcentralus" = "scus"
    "northeurope" = "ne"
    "westeurope" = "we"
    "southeastasia" = "sea"
    "japaneast" = "jpe"
    "japanwest" = "jpw"
    "brazilsouth" = "brs"
    "australiaeast" = "ae"
    "australiasoutheast" = "ase"
    "centralindia" = "inc"
    "southindia" = "ins"
    "canadacentral" = "cnc"
    "canadaeast" = "cne"
    "westcentralus" = "wcus"
    "westus2" = "wus2"
    "ukwest" = "ukw"
    "uksouth" = "uks"
    "centraluseuap" = "ccy"
    "eastus2euap" = "ecy"
    "koreasouth" = "krs"
    "koreacentral" = "krc"
    "francecentral" = "frc"
    "francesouth" = "frs"
    "australiacentral" = "acl"
    "australiacentral2" = "acl2"
    "uaecentral" = "uac"
    "uaenorth" = "uan"
    "southafricanorth" = "san"
    "southafricawest" = "saw"
    "westindia" = "inw"
    "norwayeast" = "nwe"
    "norwaywest" = "nww"
    "switzerlandnorth" = "szn"
    "switzerlandwest" = "szw"
    "germanynorth" = "gn"
    "germanywestcentral" = "gwc"
    "swedencentral" = "sdc"
    "swedensouth" = "sds"
    "brazilsoutheast" = "bse"
    "westus3" = "wus3"
    "jioindiacentral" = "jic"
    "jioindiawest" = "jiw"
    "qatarcentral" = "qac"
    "polandcentral" = "plc"
    "malaysiasouth" = "mys"
    "taiwannorth" = "twn"
    "taiwannorthwest" = "tnw"
    "israelcentral" = "ilc"
    "italynorth" = "itn"
    "mexicocentral" = "mxc"
    "spaincentral" = "spc"
    "chilecentral" = "clc"
    "newzealandnorth" = "nzn"
    "malaysiawest" = "myw"
    "indonesiacentral" = "idc"
    "southeastus" = "use"
    "usgovvirginia" = "ugv"
    "usgovarizona" = "uga"
    "usgovtexas" = "ugt"
    "usdodcentral" = "udc"
    "usdodeast" = "ude"
    "chinanorth" = "bjb"
    "chinaeast" = "sha"
    "chinanorth2" = "bjb2"
    "chinaeast2" = "sha2"
    "chinanorth3" = "bjb3"
    "chinaeast3" = "sha3"
  }
}