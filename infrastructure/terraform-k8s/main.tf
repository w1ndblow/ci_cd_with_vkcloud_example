terraform {
required_providers {
    vkcs = {
      source  = "vk-cs/vkcs"
    }
}
}

data "vkcs_kubernetes_clustertemplate" "ct" {
  version = "1.21.4"
}

resource "vkcs_kubernetes_cluster" "k8s-cluster" {
  depends_on = [
    vkcs_networking_router_interface.k8s,
  ]

  name                   = "k8s-cluster"
  cluster_template_id    = data.vkcs_kubernetes_clustertemplate.ct.id
  master_flavor          = data.vkcs_compute_flavor.k8s.id
  master_count           = 1
  network_id             = vkcs_networking_network.k8s.id
  subnet_id              = vkcs_networking_subnet.k8s-subnetwork.id
  floating_ip_enabled    = true
  availability_zone      = "MS1"
  insecure_registries    = ["1.2.3.4"]
  ingress_floating_ip    = vkcs_networking_floatingip.ingressfip.address
  loadbalancer_subnet_id = vkcs_networking_subnet.k8s-subnetwork.id
}

# TODO описать переменные
resource "vkcs_kubernetes_node_group" "groups" {
    cluster_id = vkcs_kubernetes_cluster.k8s-cluster.id

    node_count = 1
    name = "default"
    max_nodes = 5
    min_nodes = 1
}


## loadbalancer

resource "vkcs_networking_floatingip" "ingressfip" {
  pool = data.vkcs_networking_network.extnet.name
}


resource "vkcs_lb_loadbalancer" "loadbalancer" {
  name = "loadbalancer"
  vip_subnet_id = "${vkcs_networking_subnet.k8s-subnetwork.id}"
  tags = ["tag1"]
}

resource "vkcs_lb_listener" "listener" {
  name = "listener"
  protocol = "HTTP"
  protocol_port = 8080
  loadbalancer_id = "${vkcs_lb_loadbalancer.loadbalancer.id}"
}

resource "vkcs_lb_pool" "pool" {
  name = "pool"
  protocol = "HTTP"
  lb_method = "ROUND_ROBIN"
  listener_id = "${vkcs_lb_listener.listener.id}"
}

# TODO floating accociate

# resource "vkcs_networking_router" "router" {
#   name                = "router"
#   admin_state_up      = true
#   external_network_id = data.vkcs_networking_network.extnet.id
# }

# resource "vkcs_networking_router_interface" "db" {
#   router_id = vkcs_networking_router.router.id
#   subnet_id = vkcs_networking_subnet.subnetwork.id
# }

# data "vkcs_compute_flavor" "db" {
#   name = "Standard-2-8-50"
# }

# ### database
# resource "vkcs_db_instance" "db-instance" {
#   name        = "db-instance"
#   #keypair     = "${var.keypair_name}"
#   flavor_id   = data.vkcs_compute_flavor.db.id
#   size        = 8
#   volume_type = "ceph-ssd"
#   disk_autoexpand {
#     autoexpand    = true
#     max_disk_size = 1000
#   }

# network {
#     #uuid = "${vkcs_networking_subnet.k8s-subnetwork.id}"
#     uuid = vkcs_networking_network.k8s.id
#     #fixed_ip_v4 = "192.168.199.100"
# }

# datastore {
#     version = 13
#     type    = "postgresql"
# }
# }

# resource "vkcs_db_database" "app" {
#   name        = "appdb"
#   dbms_id     = "${vkcs_db_instance.db-instance.id}"
#   charset     = "utf8"
# }

# # Генерим пароль для базы
# resource "random_string" "resource_code" {
#   length  = 10
#   special = false
#   upper   = false
# }

# resource "vkcs_db_user" "app_user" {
#   name        = "app_user"
#   password    = "${random_string.resource_code.result}"
#   dbms_id     = "${vkcs_db_instance.db-instance.id}"
  
#   databases   = ["${vkcs_db_database.app.name}"]
# }

#########################
##   Output 

# output "database" {
#   value = "db_password ${random_string.resource_code.result} ${vkcs_db_instance.db-instance.network[0].fixed_ip_v4}"
# }

# resource "local_file" "prod_env" {
#   content = templatefile("${path.module}/env.tpl",
#     {
#       host = vkcs_db_instance.db-instance.network[0].fixed_ip_v4
#     }
#   )
#   filename = "../../.github/prod_env"
# }