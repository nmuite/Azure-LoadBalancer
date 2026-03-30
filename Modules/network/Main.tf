variable "vnet-name" {}
variable "vnet-cidr" {}
variable "subnet-name" {}
variable "resource-group-name" {}


output "subnet_id" {
  value = azurerm_subnet.vm-subnet.id
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet001.id
}
output "resource_group_name" {
  value = azurerm_resource_group.Loadbalance-rg.name
}

output "resource_group_location" {
  value = azurerm_resource_group.Loadbalance-rg.location
}

resource "azurerm_resource_group" "Loadbalance-rg" {
  name     = var.resource-group-name
  location = "South Africa North"
}

resource "azurerm_virtual_network" "vnet001" {
  name                = var.vnet-name
  address_space       = [var.vnet-cidr]
  location            = azurerm_resource_group.Loadbalance-rg.location
  resource_group_name = azurerm_resource_group.Loadbalance-rg.name
}

resource "azurerm_subnet" "vm-subnet" {
  name                 = var.subnet-name
  virtual_network_name = azurerm_virtual_network.vnet001.name
  address_prefixes     = [cidrsubnet(tolist(azurerm_virtual_network.vnet001.address_space)[0], 8, 1)]
  resource_group_name  = azurerm_resource_group.Loadbalance-rg.name
}
