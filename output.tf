output "volume" {
  description = "The SFS Turbo share resource. Common attributes: export_location (NFS mount target), id, size, share_proto."
  value       = opentelekomcloud_sfs_turbo_share_v1.sfs_volume
}

output "security_group" {
  description = "The security group attached to the SFS Turbo share. Reference security_group.id to attach additional ingress rules from the caller module."
  value       = opentelekomcloud_networking_secgroup_v2.sfs_volume_sg
}
