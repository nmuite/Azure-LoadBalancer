variable "resource-group-name" {}
variable "resource-group-location" {}
variable "server-nics" {}


locals {
    ext = "Dev_env_"
    tags = {
    
        Environment = "Dev"
        Owner = "Nick-Muite"
    }
}

resource "azurerm_public_ip" "lb01-pip" {
      name = "${local.ext}lb01-pip"
      location = var.resource-group-location
      resource_group_name = var.resource-group-name
      allocation_method = "Static"
      sku = "Standard"

      tags = local.tags
}
  
    

resource "azurerm_lb" "lb01" {
    name = "${local.ext}lb01"
    location = var.resource-group-location
    resource_group_name = var.resource-group-name
    frontend_ip_configuration {
        name = "${local.ext}lb01-front-pip"
        public_ip_address_id = azurerm_public_ip.lb01-pip.id
    }

}

resource "azurerm_lb_probe" "lb01-probe" {
    name = "${local.ext}lb-probe-01"
    loadbalancer_id = azurerm_lb.lb01.id
    protocol = "Tcp"
    port = 80
    
}

resource "azurerm_lb_rule" "lb-rule-01" {
    name = "${local.ext}lb-rule-01"
    loadbalancer_id = azurerm_lb.lb01.id
    protocol = "Tcp"
    frontend_port = 80
    backend_port = 80
    frontend_ip_configuration_name = azurerm_lb.lb01.frontend_ip_configuration[0].name
    backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb01-backend.id]
    probe_id = azurerm_lb_probe.lb01-probe.id
}

resource "azurerm_lb_backend_address_pool" "lb01-backend" {
    name = "${local.ext}lb01-backend-pool"
    loadbalancer_id = azurerm_lb.lb01.id

}

resource "azurerm_network_interface_backend_address_pool_association" "backend-assoc" {
    for_each = var.server-nics
    network_interface_id = each.value.id
    ip_configuration_name = each.value.ip_configuration_name
    backend_address_pool_id = azurerm_lb_backend_address_pool.lb01-backend.id
}