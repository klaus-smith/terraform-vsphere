# Basic configuration withour variables

# Define authentification configuration
provider "vsphere" {
  version              = "~> 1.5"
  user                 = "${var.vsphere_user}"
  password			   = "${var.vsphere_password}"
  vsphere_server       = "${var.vsphere_server}"
  allow_unverified_ssl = true
}

#### RETRIEVE DATA INFORMATION ON VCENTER ####

data "vsphere_datacenter" "dc" {
  name 		= "xxx"
}

data "vsphere_resource_pool" "pool" {
  # If you haven't resource pool, put "Resources" after cluster name
  name          = "xxx/Resources"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_host" "host" {
  name          = "xxx.xx"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

# Retrieve datastore information on vsphere
data "vsphere_datastore" "datastore" {
  name          = "xxx"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

# Retrieve network information on vsphere
data "vsphere_network" "network" {
  name          = "xxx"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

# Retrieve template information on vsphere
data "vsphere_virtual_machine" "template" {
  name          = "xxx"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}


resource "vsphere_folder" "folder" {
  path = "xx/xxx/xxx"
  type = "vm"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"

}

#### VM CREATION ####

# Set vm parameters
resource "vsphere_virtual_machine" "vm" {
  count 			   = 3
  name                 = "${var.servername}-${count.index + 1}"
  num_cpus             = 2
  memory               = 2048
  datastore_id         = "${data.vsphere_datastore.datastore.id}"
  host_system_id       = "${data.vsphere_host.host.id}"
  resource_pool_id     = "${data.vsphere_resource_pool.pool.id}"
  guest_id             = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type            = "${data.vsphere_virtual_machine.template.scsi_type}"
  folder			   = "${vsphere_folder.folder.path}"

  # Set network parameters
  network_interface {
    network_id         = "${data.vsphere_network.network.id}"
  }

  # Use a predefined vmware template has main disk
  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

   customize {
      linux_options {
        host_name       = "${var.servername}-${count.index + 1}"
 		domain          = "xxx"
     }

     network_interface {
    ipv4_address = "10.0.0.0"
    ipv4_netmask = 24
   }

   ipv4_gateway = "10.0.0.1"
   }   
  }
}
