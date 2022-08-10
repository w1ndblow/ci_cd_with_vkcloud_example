terraform {
required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.46.0"
    }
    vkcs = {
      source  = "vk-cs/vkcs"
      version = "0.1.6"
    }

}
}


resource "openstack_blockstorage_volume_v2" "test-volume" {
  name        = "test-volume"
  volume_type = "dp1"
  size        = "20"
  image_id    = "e0144f62-cbac-4363-9c3d-dbc7ea799f6d"
}


resource "openstack_networking_network_v2" "generic" {
  name = "network-generic"
}

resource "openstack_networking_router_v2" "generic" {
  name                = "router-generic"
  external_network_id = "298117ae-3fa4-4109-9e08-8be5602be5a2"
}


resource "openstack_networking_subnet_v2" "local" {
  name            = "local"
  network_id      = openstack_networking_network_v2.generic.id
  cidr            = "192.168.1.0/24"
  dns_nameservers = ["8.8.8.8", "8.8.8.4"]
}

# Router interface configuration
resource "openstack_networking_router_interface_v2" "local" {
  router_id = openstack_networking_router_v2.generic.id
  subnet_id = openstack_networking_subnet_v2.local.id
}

resource "openstack_networking_floatingip_v2" "myip" {
  pool = "ext-net"
}

resource "openstack_compute_floatingip_associate_v2" "ip-test-instance" {
  floating_ip = "${openstack_networking_floatingip_v2.myip.address}"
  instance_id = "${openstack_compute_instance_v2.test-instance.id}"
}


resource "vkcs_db_instance" "db-instance" {
  name        = "db-instance"
  keypair     = "${var.keypair_name}"
  flavor_id   = "25ae869c-be29-4840-8e12-99e046d2dbd4"
  size        = 8
  volume_type = "ceph-ssd"
  disk_autoexpand {
    autoexpand    = true
    max_disk_size = 1000
  }

network {
    uuid = "${openstack_networking_network_v2.generic.id}"
}

datastore {
    version = 13
    type    = "postgresql"
}
}


resource "openstack_compute_instance_v2" "test-instance" {
  name              = "test-instance"
  flavor_id         = "25ae869c-be29-4840-8e12-99e046d2dbd4"
  key_pair          = "${var.keypair_name}"
  availability_zone = "MS1"
  config_drive      = true

  security_groups = [
    "default",
    "testhttp",
    "ssh+www"
  ]

  block_device {
    uuid                  = "${openstack_blockstorage_volume_v2.test-volume.id}"
    source_type           = "volume"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  metadata = {
    env = "dev"
  }

  network {
    uuid = "${openstack_networking_network_v2.generic.id}"
  }
}


resource "vkcs_networking_secgroup" "testhttp" {
  name        = "testhttp"
  description = "http port for tests"
}



resource "vkcs_networking_secgroup_rule" "testhttp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8000
  port_range_max    = 8080
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${vkcs_networking_secgroup.testhttp.id}"
}


