# Create the cluster network and storage
resource "lxd_network" "cluster_network" {
  name = "cluster_network"

  config {
    ipv4.address = "192.168.30.1/24"
    ipv4.nat     = "true"
    ipv4.dhcp    = "true"
    ipv6.address = "none"
  }
}

resource "lxd_storage_pool" "cluster_storage_pool" {
  name = "cluster_storage_pool"
  driver = "dir"
  config {
    source = "/var/lib/lxd/storage-pools/cluster_storage_pool"
  }
}

# Create the container profiles and images
resource "lxd_profile" "cluster_profile" {
  name = "cluster_profile"

  device {
    name = "eth0"
    type = "nic"

    properties {
      nictype = "bridged"
      parent  = "${lxd_network.cluster_network.name}"
    }
  }

  device {
    type = "disk"
    name = "root"

    properties {
      pool = "${lxd_storage_pool.cluster_storage_pool.name}"
      path = "/"
    }
  }

  config {
    security.privileged = "true"
    user.vendor-data = "${file("${path.module}/vendor-data")}"
  }
}

resource "lxd_container" "pxe" {
  name      = "pxe"
  image     = "ubuntu:18.04"
  ephemeral = false
  profiles  = ["${lxd_profile.cluster_profile.name}"]
}

resource "lxd_container" "master" {
  name      = "master"
  image     = "ubuntu:18.04"
  ephemeral = false
  profiles  = ["${lxd_profile.cluster_profile.name}"]
}

resource "lxd_container" "worker" {
  name      = "worker"
  image     = "ubuntu:18.04"
  ephemeral = false
  profiles  = ["${lxd_profile.cluster_profile.name}"]
}

# Create the Ansible inventory file
data "template_file" "inventory" {
  template = "${file("${path.module}/inventory.tpl")}"

  vars {
    deployer_user = "${var.deployer_user}"
    deployer_user_key_file = "${path.module}/${var.deployer_user_key_file}"
    pxe_ip = "${lxd_container.pxe.ip_address}"
    master_ip = "${lxd_container.master.ip_address}"
    worker_ip = "${lxd_container.worker.ip_address}"
  }
}

resource "local_file" "inventory" {
    content = "${data.template_file.inventory.rendered}"
    filename = "${path.module}/inventory"
}
