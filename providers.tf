terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.10.0"
    }
    cdo = {
      source  = "CiscoDevNet/cdo"
      version = "3.2.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
    }
  }
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
  api_timeout          = 10
}

provider "cdo" {
  base_url  = var.scc_base_url
  api_token = var.scc_api_token
}

provider "time" {}