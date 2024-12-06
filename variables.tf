variable "vsphere_user" {
  description = "vSphere Username"
  type        = string
}

variable "vsphere_password" {
  description = "vSphere Password"
  type        = string
  sensitive   = true
}

variable "vsphere_server" {
  description = "vCenter Server FQDN or IP Address"
  type        = string
}

variable "prefix" {
  description = "Prefix for resources created by the template"
  type        = string
  default     = "ACME"
}

variable "datacenter" {
  description = "vCenter Datacenter Name"
  type        = string
}

variable "host" {
  description = "ESXi Host FQDN or IP Address"
  type        = string
}

variable "datastore" {
  description = "Datastore Name"
  type        = string
  default     = "disk72-2-raid0"
}

variable "child_resource_pools" {
  description = "List of Child Resource Pools to be created"
  type        = list(string)
  default     = ["Management", "Corporate", "Branch-1", "Traffic-Generator", "Datacenter-1", "Datacenter-2", "SW-Appliance", "FDM", "Guest", "DMZ"]
}

variable "port_groups" {
  description = "Map of Port Group Names"
  type        = map(string)
  default = {
    "Management"   = "ACME-Management",
    "Corporate"    = "ACME-Corporate",
    "Branch-1"     = "ACME-Branch-1",
    "TG-1"         = "ACME-TG-1",
    "TG-2"         = "ACME-TG-2",
    "Datacenter-1" = "ACME-Datacenter-1",
    "Datacenter-2" = "ACME-Datacenter-2",
    "SW-Appliance" = "ACME-SW-Appliance",
    "FDM"          = "ACME-FDM",
    "Guest"        = "ACME-Guest",
    "DMZ"          = "ACME-DMZ",
    "Cisco-DMZ"    = "CISCO_DMZ"
  }
}

variable "password" {
  description = "Password to be set in all the resources created by the template"
  type        = string
  sensitive   = true
}

variable "scc_api_token" {
  description = "SCC API Token"
  type        = string
  sensitive   = true
}

variable "scc_base_url" {
  description = "SCC Base URL"
  type        = string
}

variable "cdfmc_managed_ftds" {
  description = "List of cdFMC managed FTDs"
  type        = list(string)
  default     = ["Corporate", "Branch-1", "Traffic-Generator", "Datacenter"]
}