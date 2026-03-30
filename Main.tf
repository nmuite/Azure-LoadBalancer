module "Networks" {
    source = "./Modules/network"
    vnet-name = var.vnet-name
    vnet-cidr = var.vnet-cidr
    subnet-name = var.subnet-name
    resource-group-name = var.resource-group-name
} 

module "servers" {
    source = "./Modules/servers"
    resource-group-name = module.Networks.resource_group_name
    resource-group-location = module.Networks.resource_group_location
    subnet_id = module.Networks.subnet_id

}

module "LoadBalancer" {
    source = "./Modules/LoadBalancer"
    resource-group-name = module.Networks.resource_group_name
    resource-group-location = module.Networks.resource_group_location
    server-nics = module.servers.server-nic-ids
}