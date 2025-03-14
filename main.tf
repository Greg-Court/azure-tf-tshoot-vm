provider "azurerm" {
  features {}
  subscription_id = local.subscription_id
}

locals {
  common_tags = {
    "Purpose"    = "Troubleshooting"
    "Temporary"  = "True"
    "DeployedOn" = formatdate("YYYY-MM-DD", timestamp())
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