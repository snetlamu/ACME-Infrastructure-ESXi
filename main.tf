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
    datastore_id = data.vsphere_datastore.Datastore.id
    path         = "/${var.prefix}-CSR1000v/_deviceImage-0.iso"
  }

  cdrom {
    client_device = true
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

# SCC

resource "cdo_ftd_device" "SCC-FTDs" {
  for_each           = toset(var.cdfmc_managed_ftds)
  name               = "${each.value}-FTD"
  access_policy_name = "Default Access Control Policy"
  licenses           = ["BASE", "CARRIER", "THREAT", "MALWARE", "URLFilter"]
  virtual            = true
  performance_tier   = "FTDv"
}

# Corporate

resource "vsphere_virtual_machine" "Corporate-FTD" {
  name     = "${var.prefix}-Corporate-FTD"
  num_cpus = 8
  memory   = 16 * 1024

  resource_pool_id           = vsphere_resource_pool.Child-Pools["Corporate"].id
  datastore_id               = data.vsphere_datastore.Datastore.id
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
  scsi_type                  = "lsilogic"

  clone {
    template_uuid = data.vsphere_content_library_item.FTDv-7-6.id
  }

  disk {
    datastore_id     = data.vsphere_datastore.Datastore.id
    label            = "disk0"
    size             = 40
    thin_provisioned = true
    controller_type  = "scsi"
  }

  network_interface {
    ovf_mapping = "Management0-0"
    network_id  = data.vsphere_network.Port-Groups["Management"].id
  }

  network_interface {
    ovf_mapping = "Diagnostic"
    network_id  = data.vsphere_network.Port-Groups["Management"].id
  }

  network_interface {
    ovf_mapping = "GigabitEthernet0-0"
    network_id  = data.vsphere_network.Port-Groups["Corporate"].id
  }

  network_interface {
    ovf_mapping = "GigabitEthernet0-1"
    network_id  = data.vsphere_network.Port-Groups["Guest"].id
  }

  network_interface {
    ovf_mapping = "GigabitEthernet0-2"
    network_id  = data.vsphere_network.Port-Groups["DMZ"].id
  }

  network_interface {
    ovf_mapping = "GigabitEthernet0-3"
    network_id  = data.vsphere_network.Port-Groups["Cisco-DMZ"].id
  }

  cdrom {
    client_device = true
  }

  vapp {
    properties = {
      "pw"            = var.password,
      "ipv4.how"      = "Manual",
      "ipv4.addr"     = "10.0.100.110",
      "ipv4.gw"       = "10.0.100.1",
      "fqdn"          = "corporate-ftd",
      "firewallmode"  = "routed",
      "dns1"          = "208.67.222.222",
      "dns2"          = "208.67.220.220",
      "dns3"          = "10.0.100.102",
      "manageLocally" = "No",
      "mgr"           = data.cdo_cdfmc.cdFMC.hostname,
      "regkey"        = cdo_ftd_device.SCC-FTDs["Corporate"].reg_key,
      "regNAT"        = cdo_ftd_device.SCC-FTDs["Corporate"].nat_id
    }
  }
}

# Branch-1

resource "vsphere_virtual_machine" "Branch-1-FTD" {
  name     = "${var.prefix}-Branch-1-FTD"
  num_cpus = 8
  memory   = 16 * 1024

  resource_pool_id           = vsphere_resource_pool.Child-Pools["Branch-1"].id
  datastore_id               = data.vsphere_datastore.Datastore.id
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
  scsi_type                  = "lsilogic"

  clone {
    template_uuid = data.vsphere_content_library_item.FTDv-7-6.id
  }

  disk {
    datastore_id     = data.vsphere_datastore.Datastore.id
    label            = "disk0"
    size             = 40
    thin_provisioned = true
    controller_type  = "scsi"
  }

  network_interface {
    ovf_mapping = "Management0-0"
    network_id  = data.vsphere_network.Port-Groups["Management"].id
  }

  network_interface {
    ovf_mapping = "Diagnostic"
    network_id  = data.vsphere_network.Port-Groups["Management"].id
  }

  network_interface {
    ovf_mapping = "GigabitEthernet0-0"
    network_id  = data.vsphere_network.Port-Groups["Branch-1"].id
  }

  network_interface {
    ovf_mapping = "GigabitEthernet0-1"
    network_id  = data.vsphere_network.Port-Groups["Corporate"].id
  }

  cdrom {
    client_device = true
  }

  vapp {
    properties = {
      "pw"            = var.password,
      "ipv4.how"      = "Manual",
      "ipv4.addr"     = "10.0.100.111",
      "ipv4.gw"       = "10.0.100.1",
      "ipv4.mask"     = "255.255.255.0",
      "fqdn"          = "branch-1-ftd",
      "firewallmode"  = "routed",
      "dns1"          = "208.67.222.222",
      "dns2"          = "208.67.220.220",
      "dns3"          = "10.0.100.102",
      "manageLocally" = "No",
      "mgr"           = data.cdo_cdfmc.cdFMC.hostname,
      "regkey"        = cdo_ftd_device.SCC-FTDs["Branch-1"].reg_key,
      "regNAT"        = cdo_ftd_device.SCC-FTDs["Branch-1"].nat_id
    }
  }
}

# Traffic Generator

resource "vsphere_virtual_machine" "Traffic-Generator-FTD" {
  name     = "${var.prefix}-Traffic-Generator-FTD"
  num_cpus = 8
  memory   = 16 * 1024

  resource_pool_id           = vsphere_resource_pool.Child-Pools["Traffic-Generator"].id
  datastore_id               = data.vsphere_datastore.Datastore.id
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
  scsi_type                  = "lsilogic"

  clone {
    template_uuid = data.vsphere_content_library_item.FTDv-7-6.id
  }

  disk {
    datastore_id     = data.vsphere_datastore.Datastore.id
    label            = "disk0"
    size             = 40
    thin_provisioned = true
    controller_type  = "scsi"
  }

  network_interface {
    ovf_mapping = "Management0-0"
    network_id  = data.vsphere_network.Port-Groups["Management"].id
  }

  network_interface {
    ovf_mapping = "Diagnostic"
    network_id  = data.vsphere_network.Port-Groups["Management"].id
  }

  network_interface {
    ovf_mapping = "GigabitEthernet0-0"
    network_id  = data.vsphere_network.Port-Groups["TG-1"].id
  }

  network_interface {
    ovf_mapping = "GigabitEthernet0-1"
    network_id  = data.vsphere_network.Port-Groups["TG-2"].id
  }

  network_interface {
    ovf_mapping = "GigabitEthernet0-2"
    network_id  = data.vsphere_network.Port-Groups["Corporate"].id
  }

  cdrom {
    client_device = true
  }

  vapp {
    properties = {
      "pw"            = var.password,
      "ipv4.how"      = "Manual",
      "ipv4.addr"     = "10.0.100.112",
      "ipv4.gw"       = "10.0.100.1",
      "ipv4.mask"     = "255.255.255.0",
      "fqdn"          = "traffic-generator-ftd",
      "firewallmode"  = "routed",
      "dns1"          = "208.67.222.222",
      "dns2"          = "208.67.220.220",
      "dns3"          = "10.0.100.102",
      "manageLocally" = "No",
      "mgr"           = data.cdo_cdfmc.cdFMC.hostname,
      "regkey"        = cdo_ftd_device.SCC-FTDs["Traffic-Generator"].reg_key,
      "regNAT"        = cdo_ftd_device.SCC-FTDs["Traffic-Generator"].nat_id
    }
  }
}

# Datacenter

resource "vsphere_virtual_machine" "Datacenter-FTD" {
  name     = "${var.prefix}-Datacenter-FTD"
  num_cpus = 8
  memory   = 16 * 1024

  resource_pool_id           = vsphere_resource_pool.Child-Pools["Datacenter"].id
  datastore_id               = data.vsphere_datastore.Datastore.id
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
  scsi_type                  = "lsilogic"

  clone {
    template_uuid = data.vsphere_content_library_item.FTDv-7-6.id
  }

  disk {
    datastore_id     = data.vsphere_datastore.Datastore.id
    label            = "disk0"
    size             = 40
    thin_provisioned = true
    controller_type  = "scsi"
  }

  network_interface {
    ovf_mapping = "Management0-0"
    network_id  = data.vsphere_network.Port-Groups["Management"].id
  }

  network_interface {
    ovf_mapping = "Diagnostic"
    network_id  = data.vsphere_network.Port-Groups["Management"].id
  }

  network_interface {
    ovf_mapping = "GigabitEthernet0-0"
    network_id  = data.vsphere_network.Port-Groups["Datacenter-1"].id
  }

  network_interface {
    ovf_mapping = "GigabitEthernet0-1"
    network_id  = data.vsphere_network.Port-Groups["Datacenter-2"].id
  }

  network_interface {
    ovf_mapping = "GigabitEthernet0-2"
    network_id  = data.vsphere_network.Port-Groups["SW-Appliance"].id
  }

  network_interface {
    ovf_mapping = "GigabitEthernet0-3"
    network_id  = data.vsphere_network.Port-Groups["Corporate"].id
  }

  cdrom {
    client_device = true
  }

  vapp {
    properties = {
      "pw"            = var.password,
      "ipv4.how"      = "Manual",
      "ipv4.addr"     = "10.0.100.113",
      "ipv4.gw"       = "10.0.100.1",
      "ipv4.mask"     = "255.255.255.0",
      "fqdn"          = "datacenter-ftd",
      "firewallmode"  = "routed",
      "dns1"          = "208.67.222.222",
      "dns2"          = "208.67.220.220",
      "dns3"          = "10.0.100.102",
      "manageLocally" = "No",
      "mgr"           = data.cdo_cdfmc.cdFMC.hostname,
      "regkey"        = cdo_ftd_device.SCC-FTDs["Datacenter"].reg_key,
      "regNAT"        = cdo_ftd_device.SCC-FTDs["Datacenter"].nat_id
    }
  }
}

# FDM

resource "vsphere_virtual_machine" "FDM-FTD" {
  name     = "${var.prefix}-FDM-FTD"
  num_cpus = 8
  memory   = 16 * 1024

  resource_pool_id           = vsphere_resource_pool.Child-Pools["FDM"].id
  datastore_id               = data.vsphere_datastore.Datastore.id
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
  scsi_type                  = "lsilogic"

  clone {
    template_uuid = data.vsphere_content_library_item.FTDv-7-6.id
  }

  disk {
    datastore_id     = data.vsphere_datastore.Datastore.id
    label            = "disk0"
    size             = 40
    thin_provisioned = true
    controller_type  = "scsi"
  }

  network_interface {
    ovf_mapping = "Management0-0"
    network_id  = data.vsphere_network.Port-Groups["Management"].id
  }

  network_interface {
    ovf_mapping = "Diagnostic"
    network_id  = data.vsphere_network.Port-Groups["Management"].id
  }

  network_interface {
    ovf_mapping = "GigabitEthernet0-0"
    network_id  = data.vsphere_network.Port-Groups["FDM"].id
  }

  network_interface {
    ovf_mapping = "GigabitEthernet0-1"
    network_id  = data.vsphere_network.Port-Groups["Corporate"].id
  }

  cdrom {
    client_device = true
  }

  vapp {
    properties = {
      "pw"            = var.password,
      "ipv4.how"      = "Manual",
      "ipv4.addr"     = "10.0.100.114",
      "ipv4.gw"       = "10.0.100.1",
      "ipv4.mask"     = "255.255.255.0",
      "fqdn"          = "fdm-ftd",
      "firewallmode"  = "routed",
      "dns1"          = "208.67.222.222",
      "dns2"          = "208.67.220.220",
      "dns3"          = "10.0.100.102",
      "manageLocally" = "Yes"
    }
  }
}