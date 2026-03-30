variable "resource-group-name" {}
variable "resource-group-location" {}
variable "subnet_id" {}


output "server-nic-ids" {
  value =  {
    for k, nic in azurerm_network_interface.vm01-nic : k => {
      id                 = nic.id
      ip_configuration_name = nic.ip_configuration[index(nic.ip_configuration.*.primary, true)].name
    }
  }
}

locals {
  zones = toset(["1", "2"])
  vm_image = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

  resource "azurerm_public_ip" "vm001-ext-nic-pip" {
  for_each            = local.zones
  name                = "vm001-ext-nic-${each.value}-pip"
  location            = var.resource-group-location
  resource_group_name = var.resource-group-name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [each.value]
}


resource "azurerm_network_interface" "vm01-nic" {
  for_each            = local.zones
  name                = "vm01-external-nic-${each.value}"
  location            = var.resource-group-location
  resource_group_name = var.resource-group-name
  ip_configuration {
    name                          = "vm01-ext-nic-ip"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm001-ext-nic-pip[each.value].id
  }
} 

resource "azurerm_linux_virtual_machine" "vm001" {
  for_each              = local.zones
  name                  = "lb-test-vm-${each.value}"
  size                  = "Standard_DS1_v2"
  location              = var.resource-group-location
  resource_group_name   = var.resource-group-name
  network_interface_ids = [azurerm_network_interface.vm01-nic[each.value].id]
  admin_username        = "nmuite"
  admin_password        = "Eva@23129946"
  zone                  = each.value
  disable_password_authentication = false

  source_image_reference {
    publisher = local.vm_image.publisher
    offer     = local.vm_image.offer
    sku       = local.vm_image.sku
    version   = local.vm_image.version
  }

  os_disk {
    name                 = "vm001-os-${each.value}-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
} 

resource "azurerm_network_security_group" "sec-grp01" {
  name = "sec-grp-01"
  location = var.resource-group-location
  resource_group_name = var.resource-group-name
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "allow-ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  resource_group_name         = var.resource-group-name
  network_security_group_name = azurerm_network_security_group.sec-grp01.name
}

resource "azurerm_network_security_rule" "allow_http" {
  name                        = "allow-http"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  resource_group_name         = var.resource-group-name
  network_security_group_name = azurerm_network_security_group.sec-grp01.name
}

/*resource "azurerm_network_security_group_association" "sec-grp01-association" {
  network_interface_id      = azurerm_network_interface.vm01-nic.id
  network_security_group_id = azurerm_network_security_group.sec-grp01.id
} */

resource "azurerm_subnet_network_security_group_association" "subnet-sec-grp01-association" {
  subnet_id                 = var.subnet_id
  network_security_group_id = azurerm_network_security_group.sec-grp01.id
} 

