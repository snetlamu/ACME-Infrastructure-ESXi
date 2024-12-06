data "vsphere_datacenter" "datacenter" {
  name = var.datacenter
}

data "vsphere_host" "host" {
  datacenter_id = data.vsphere_datacenter.datacenter.id
  name = var.host
}