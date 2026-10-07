resource "random_id" "sfs_volume_kms_id" {
  count       = var.kms_key_create ? 1 : 0
  byte_length = 4
}

resource "opentelekomcloud_kms_key_v1" "sfs_volume_kms_key" {
  count           = var.kms_key_create ? 1 : 0
  key_alias       = "${var.volume_name}-SFS-${random_id.sfs_volume_kms_id[0].hex}"
  key_description = "${var.volume_name} SFS volume encryption key"
  pending_days    = 7
  is_enabled      = "true"
}

resource "opentelekomcloud_networking_secgroup_v2" "sfs_volume_sg" {
  name        = "${var.volume_name}-SFS-secgroup"
  description = "${var.volume_name} SFS security group for network accessibility."
}

data "opentelekomcloud_vpc_subnet_v1" "subnet" {
  id = var.subnet_id
}

locals {
  sg_allowed_cidr = var.sg_allowed_cidr == null ? [data.opentelekomcloud_vpc_subnet_v1.subnet.cidr] : var.sg_allowed_cidr
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "secgroup_rule_mounting_tcp" {
  for_each = { for cidr_port in setproduct(local.sg_allowed_cidr, [
    "111",
    "2049",
    "2051",
    "20048",
    "2052",
    ]) : join("_", cidr_port) => {
    cidr = length(split("/", cidr_port[0])) == 2 ? cidr_port[0] : "${cidr_port[0]}/32"
    port = tonumber(cidr_port[1])
  } }

  description       = "Allowed IP address ranges to access and mount the SFS disk."
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = each.value.port
  port_range_max    = each.value.port
  remote_ip_prefix  = each.value.cidr
  security_group_id = opentelekomcloud_networking_secgroup_v2.sfs_volume_sg.id
}


resource "opentelekomcloud_networking_secgroup_rule_v2" "secgroup_rule_mounting_udp" {
  for_each = { for cidr_port in setproduct(local.sg_allowed_cidr, [
    "111",
    "20048",
    ]) : join("_", cidr_port) => {
    cidr = length(split("/", cidr_port[0])) == 2 ? cidr_port[0] : "${cidr_port[0]}/32"
    port = tonumber(cidr_port[1])
  } }

  description       = "Allowed IP address ranges to access and mount the SFS disk."
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = each.value.port
  port_range_max    = each.value.port
  remote_ip_prefix  = each.value.cidr
  security_group_id = opentelekomcloud_networking_secgroup_v2.sfs_volume_sg.id
}

resource "opentelekomcloud_sfs_turbo_share_v1" "sfs_volume" {
  name              = var.volume_name
  availability_zone = var.availability_zone
  size              = var.size
  share_proto       = "NFS"
  share_type        = var.share_type
  vpc_id            = var.vpc_id
  subnet_id         = var.subnet_id
  security_group_id = opentelekomcloud_networking_secgroup_v2.sfs_volume_sg.id
  crypt_key_id      = var.kms_key_create ? opentelekomcloud_kms_key_v1.sfs_volume_kms_key[0].id : var.kms_key_id
  timeouts {
    create = "30m"
  }
  lifecycle {
    ignore_changes = [available_capacity]
  }
}
