## Scalable File Service (SFS Turbo)

Provisions an SFS Turbo share with its own security group, ingress rules covering the NFSv3 wire ports, an optional KMS key for at-rest encryption, and an optional CBR-backed backup schedule.

Ingress defaults to the CIDR of the subnet the share is provisioned in, so hosts in that subnet can mount out of the box. Callers can widen the allowed range via `sg_allowed_cidr` when other subnets (jumphost, sibling stages, VPC peer) also need to mount the same share.

Earlier releases of this module produced shares whose ingress rules were populated by OTC's SFS Turbo control plane rather than by Terraform. That behavior was removed silently at the cloud level; fresh applies now produce empty security groups and mounts hang on portmap timeouts (masked by the `bg` fstab option, which reports `successfully mounted` while nothing is actually mounted). Note that OTC's [SFS FAQ](https://docs.otc.t-systems.com/scalable-file-service/umn/faqs/networks/does_the_security_group_of_a_vpc_affect_sfs.html) as of this release still describes the auto-inject as active. The docs are out of sync with observed cloud behavior. This release makes ingress explicit so mounts work regardless of what the control plane does.

### Usage

#### Minimal

```hcl
module "sfs" {
  source = "iits-consulting/sfs/opentelekomcloud"

  volume_name       = "${var.context}-${var.stage}-shared"
  vpc_id            = module.vpc.vpc.id
  subnet_id         = module.vpc.subnets["kubernetes-subnet"].id
  availability_zone = var.availability_zones[0]
}
```

Hosts in `kubernetes-subnet` can mount. Nothing else in the VPC can.

#### Access from additional subnets

Pass a full list. Values REPLACE the default, so include the mount subnet alongside any additional CIDRs you want to permit.

```hcl
module "sfs" {
  source = "iits-consulting/sfs/opentelekomcloud"

  volume_name       = "${var.context}-${var.stage}-shared"
  vpc_id            = module.vpc.vpc.id
  subnet_id         = module.vpc.subnets["kubernetes-subnet"].id
  availability_zone = var.availability_zones[0]

  sg_allowed_cidr = [
    module.vpc.subnets["kubernetes-subnet"].cidr,
    module.vpc.subnets["jumphost-subnet"].cidr,
  ]
}
```

#### Existing KMS key

```hcl
module "sfs" {
  source = "iits-consulting/sfs/opentelekomcloud"

  volume_name    = "${var.context}-${var.stage}-shared"
  vpc_id         = module.vpc.vpc.id
  subnet_id      = module.vpc.subnets["kubernetes-subnet"].id
  kms_key_create = false
  kms_key_id     = var.existing_kms_key_id
}
```

#### Backup disabled

```hcl
module "sfs" {
  source = "iits-consulting/sfs/opentelekomcloud"

  volume_name    = "${var.context}-${var.stage}-shared"
  vpc_id         = module.vpc.vpc.id
  subnet_id      = module.vpc.subnets["kubernetes-subnet"].id
  backup_enabled = false
}
```

### Network access

The module attaches the following ingress rules to its security group, one entry per (protocol, port, CIDR) combination in `sg_allowed_cidr`:

| Protocol | Ports                                                            |
|----------|------------------------------------------------------------------|
| TCP      | 111 (portmap), 2049 (NFS), 2051 (nsm), 2052 (rquotad), 20048 (mountd) |
| UDP      | 111 (portmap), 20048 (mountd)                                    |

OTC applies the SFS Turbo security group at the share, not at the mounting host's ENI. Widening `sg_allowed_cidr` is sufficient; no matching client-side rule is needed as long as intra-VPC egress on the client is open (the default on OTC-provided security groups).

### Migration from 7.4.2 and earlier

**Delete the legacy 0.0.0.0/0 ingress rules on the SFS share's security group before or shortly after upgrading.** Earlier releases relied on OTC's SFS Turbo control plane to auto-inject wide-open (0.0.0.0/0) NFS ingress. Those rules are not managed by Terraform, so a `tofu apply` will not remove them. Leaving them in place defeats the purpose of `sg_allowed_cidr`: any host in the VPC continues to reach the share regardless of what CIDRs the module attaches. Removal is a one-time manual step per SFS share, via the OTC console or a `terraform import` + `tofu destroy` of each stray rule.

On the next apply, Terraform will propose to create the ingress rules the module now manages. This is expected.

If your caller module attached its own `opentelekomcloud_networking_secgroup_rule_v2` entries to this module's SG, review them for duplication before applying.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_opentelekomcloud"></a> [opentelekomcloud](#requirement\_opentelekomcloud) | ~> 1.35 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_opentelekomcloud"></a> [opentelekomcloud](#provider\_opentelekomcloud) | ~> 1.35 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [opentelekomcloud_cbr_policy_v3.backup_policy](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/cbr_policy_v3) | resource |
| [opentelekomcloud_cbr_vault_v3.backup_vault](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/cbr_vault_v3) | resource |
| [opentelekomcloud_kms_key_v1.sfs_volume_kms_key](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/kms_key_v1) | resource |
| [opentelekomcloud_networking_secgroup_rule_v2.secgroup_rule_mounting_tcp](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/networking_secgroup_rule_v2) | resource |
| [opentelekomcloud_networking_secgroup_rule_v2.secgroup_rule_mounting_udp](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/networking_secgroup_rule_v2) | resource |
| [opentelekomcloud_networking_secgroup_v2.sfs_volume_sg](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/networking_secgroup_v2) | resource |
| [opentelekomcloud_sfs_turbo_share_v1.sfs_volume](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/sfs_turbo_share_v1) | resource |
| [random_id.sfs_volume_kms_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [opentelekomcloud_vpc_subnet_v1.subnet](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/data-sources/vpc_subnet_v1) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet network id where the SFS volume will be created in. | `string` | n/a | yes |
| <a name="input_volume_name"></a> [volume\_name](#input\_volume\_name) | Volume name for the SFS Turbo resource. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC id where the SFS volume will be created in. | `string` | n/a | yes |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | Availability zone for the SFS Turbo resource. | `string` | `"eu-de-01"` | no |
| <a name="input_backup_enabled"></a> [backup\_enabled](#input\_backup\_enabled) | Enable SFS volume backups via CBR Vault. | `bool` | `true` | no |
| <a name="input_backup_retention_days"></a> [backup\_retention\_days](#input\_backup\_retention\_days) | Retention duration of SFS volume backups in days. | `number` | `13` | no |
| <a name="input_backup_size"></a> [backup\_size](#input\_backup\_size) | Size of the SFS volume backup vault in GB. | `number` | `1000` | no |
| <a name="input_backup_trigger_pattern"></a> [backup\_trigger\_pattern](#input\_backup\_trigger\_pattern) | Backup trigger pattern to define backup schedule (iCalender RFC 2445). See https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/1.35.7/docs/resources/cbr_policy_v3#trigger_pattern for details. | `list(string)` | <pre>[<br/>  "FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR,SA,SU;BYHOUR=00;BYMINUTE=00"<br/>]</pre> | no |
| <a name="input_kms_key_create"></a> [kms\_key\_create](#input\_kms\_key\_create) | Whether the module should create a new KMS key for at-rest encryption. Set false and pass kms\_key\_id to use an existing one. | `bool` | `true` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | Existing KMS Key ID for server side encryption if one is already created. | `string` | `null` | no |
| <a name="input_sg_allowed_cidr"></a> [sg\_allowed\_cidr](#input\_sg\_allowed\_cidr) | CIDR ranges or IPs allowed to mount the SFS share. When set, replaces the default (the mount subnet CIDR); include the mount subnet if hosts there also need access. | `set(string)` | `null` | no |
| <a name="input_share_type"></a> [share\_type](#input\_share\_type) | Filesystem type of the SFS volume. | `string` | `"STANDARD"` | no |
| <a name="input_size"></a> [size](#input\_size) | Size of the SFS volume in GB. | `number` | `500` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_security_group"></a> [security\_group](#output\_security\_group) | The security group attached to the SFS Turbo share. Reference security\_group.id to attach additional ingress rules from the caller module. |
| <a name="output_volume"></a> [volume](#output\_volume) | The SFS Turbo share resource. Common attributes: export\_location (NFS mount target), id, size, share\_proto. |
<!-- END_TF_DOCS -->
