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

variable "clusters" {
  description = "List of clusters to be created"
  type        = list(string)
  default     = ["Management", "Corporate", "Datacenter-1", "Datacenter-2", "Branch-1", "Traffic Generator", "DMZ", "Guest", "FDM"]
}