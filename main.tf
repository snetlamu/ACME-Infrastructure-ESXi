# Resource Pools
resource "vsphere_resource_pool" "Parent-Pool" {
  parent_resource_pool_id = data.vsphere_host.Host.resource_pool_id
  name                    = "${var.prefix}-Infrastructure"
}

resource "vsphere_resource_pool" "Child-Pools" {
  for_each                = toset(var.child_resource_pools)
  parent_resource_pool_id = vsphere_resource_pool.Parent-Pool.id
  name                    = "${var.prefix}-${each.value}"
}

# Management
resource "vsphere_virtual_machine" "Router" {
  name     = "${var.prefix}-CSR1000v"
  num_cpus = 4
  memory   = 4 * 1024

  resource_pool_id           = vsphere_resource_pool.Child-Pools["Management"].id
  datastore_id               = data.vsphere_datastore.Datastore.id
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
  scsi_type                  = "pvscsi"

  disk {
    datastore_id     = data.vsphere_datastore.Datastore.id
    label            = "disk0"
    size             = 10
    thin_provisioned = true
    controller_type  = "scsi"
  }

  cdrom {
    client_device = true
  }

  cdrom {
    datastore_id = data.vsphere_datastore.Datastore.id
    path = "/${var.prefix}-CSR1000v/_deviceImage-0.iso"
  }


  clone {
    template_uuid = data.vsphere_content_library_item.CSR1000v.id
  }

  network_interface {
    ovf_mapping = "GigabitEthernet1"
    network_id  = data.vsphere_network.Port-Groups["Management"].id
  }

  network_interface {
    ovf_mapping = "GigabitEthernet2"
    network_id  = data.vsphere_network.Port-Groups["Cisco-DMZ"].id
  }

  network_interface {
    ovf_mapping = "GigabitEthernet3"
    network_id  = data.vsphere_network.Port-Groups["Management"].id
  }

  vapp {
    properties = {
      "hostname"          = "management-router",
      "login-username"    = "admin",
      "login-password"    = var.password,
      "mgmt-ipv4-addr"    = "10.0.100.1/24",
      "mgmt-ipv4-network" = "10.0.100.0/24"
    }
  }
}

# Corporate


# Branch-1


# Traffic Generator


# Datacenter-1


# Datacenter-2


# SW-Appliance


# FDM


# Guest


# DMZ

