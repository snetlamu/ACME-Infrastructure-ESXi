data "vsphere_datacenter" "Datacenter" {
  name = var.datacenter
}

data "vsphere_host" "Host" {
  datacenter_id = data.vsphere_datacenter.Datacenter.id
  name          = var.host
}

data "vsphere_content_library" "Router-Images" {
  name = "CSRv-Images"
}

data "vsphere_content_library_item" "CSR1000v" {
  name       = "CSR1000v-9.17.03.04a"
  type       = "ovf"
  library_id = data.vsphere_content_library.Router-Images.id
}

data "vsphere_datastore" "Datastore" {
  name          = "disk72-2-raid0"
  datacenter_id = data.vsphere_datacenter.Datacenter.id
}

data "vsphere_network" "Port-Groups" {
  for_each      = var.port_groups
  datacenter_id = data.vsphere_datacenter.Datacenter.id
  name          = each.value
}