resource "vsphere_compute_cluster" "Infrastructure" {
  datacenter_id = data.vsphere_datacenter.datacenter.id
  host_system_ids = [ data.vsphere_host.host.id ]
  name = "${var.prefix}-Infrastructure"
}

resource "vsphere_compute_cluster" "Management" {
  for_each = toset(var.clusters)
  datacenter_id = data.vsphere_datacenter.datacenter.id
  host_system_ids = [ vsphere_compute_cluster.Infrastructure.id ]
  name = "${var.prefix}-${each.value}"
}