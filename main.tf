resource "vsphere_resource_pool" "Parent_Pool" {
  parent_resource_pool_id = data.vsphere_host.host.resource_pool_id
  name                    = "${var.prefix}-Infrastructure"
}

resource "vsphere_resource_pool" "Child_Pools" {
  for_each                = toset(var.clusters)
  parent_resource_pool_id = vsphere_resource_pool.Parent_Pool.id
  name                    = "${var.prefix}-${each.value}"
}