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
    user.vendor-data = "${file("vendor-data")}"
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

resource "lxd_container" "node" {
  name      = "node"
  image     = "ubuntu:18.04"
  ephemeral = false
  profiles  = ["${lxd_profile.cluster_profile.name}"]
}