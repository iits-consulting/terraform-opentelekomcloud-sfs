## Scalable File Service (SFS)

A module designed to create and manage SFS volumes with configurable encryption and backup systems.

Usage example:

```hcl
module "sfs" {
  source     = "iits-consulting/sfs/opentelekomcloud"
  version    = "6.0.2"

  availability_zone = "eu-de-01"
  vpc_id            = module.vpc.vpc.id
  subnet_id         = module.vpc.subnets["mysubnet"].id
  volume_name       = "myvolume"
}
```

<!-- BEGIN_TF_DOCS -->

## Requirements

No requirements.

## Providers

| Name                                                                                    | Version |
| --------------------------------------------------------------------------------------- | ------- |
| <a name="provider_opentelekomcloud"></a> [opentelekomcloud](#provider_opentelekomcloud) | n/a     |
| <a name="provider_random"></a> [random](#provider_random)                               | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                            | Type     |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [opentelekomcloud_cbr_policy_v3.backup_policy](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/cbr_policy_v3)                   | resource |
| [opentelekomcloud_cbr_vault_v3.backup_vault](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/cbr_vault_v3)                      | resource |
| [opentelekomcloud_kms_key_v1.sfs_volume_kms_key](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/kms_key_v1)                    | resource |
| [opentelekomcloud_networking_secgroup_v2.sfs_volume_sg](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/networking_secgroup_v2) | resource |
| [opentelekomcloud_sfs_turbo_share_v1.sfs_volume](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/sfs_turbo_share_v1)            | resource |
| [random_id.sfs_volume_kms_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id)                                                                | resource |

## Inputs

| Name                                                                                                | Description                                                                                                                                                                                                           | Type           | Default                                                                                | Required |
| --------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | -------------------------------------------------------------------------------------- | :------: |
| <a name="input_subnet_id"></a> [subnet_id](#input_subnet_id)                                        | Subnet network id where the SFS volume will be created in.                                                                                                                                                            | `string`       | n/a                                                                                    |   yes    |
| <a name="input_volume_name"></a> [volume_name](#input_volume_name)                                  | Volume name for the SFS Turbo resource.                                                                                                                                                                               | `string`       | n/a                                                                                    |   yes    |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id)                                                 | VPC id where the SFS volume will be created in.                                                                                                                                                                       | `string`       | n/a                                                                                    |   yes    |
| <a name="input_availability_zone"></a> [availability_zone](#input_availability_zone)                | Availability zone for the SFS Turbo resource.                                                                                                                                                                         | `string`       | `"eu-de-01"`                                                                           |    no    |
| <a name="input_backup_enabled"></a> [backup_enabled](#input_backup_enabled)                         | Enable SFS volume backups via CBR Vault.                                                                                                                                                                              | `bool`         | `true`                                                                                 |    no    |
| <a name="input_backup_retention_days"></a> [backup_retention_days](#input_backup_retention_days)    | Retention duration of SFS volume backups in days.                                                                                                                                                                     | `number`       | `13`                                                                                   |    no    |
| <a name="input_backup_size"></a> [backup_size](#input_backup_size)                                  | Size of the SFS volume backup vault in GB.                                                                                                                                                                            | `number`       | `1000`                                                                                 |    no    |
| <a name="input_backup_trigger_pattern"></a> [backup_trigger_pattern](#input_backup_trigger_pattern) | Backup trigger pattern to define backup schedule (iCalender RFC 2445). See https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/1.35.7/docs/resources/cbr_policy_v3#trigger_pattern for details. | `list(string)` | <pre>[<br/> "FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR,SA,SU;BYHOUR=00;BYMINUTE=00"<br/>]</pre> |    no    |
| <a name="input_kms_key_create"></a> [kms_key_create](#input_kms_key_create)                         | Existing KMS Key ID if one is already created.                                                                                                                                                                        | `bool`         | `true`                                                                                 |    no    |
| <a name="input_kms_key_id"></a> [kms_key_id](#input_kms_key_id)                                     | Existing KMS Key ID for server side encryption if one is already created.                                                                                                                                             | `string`       | `null`                                                                                 |    no    |
| <a name="input_share_type"></a> [share_type](#input_share_type)                                     | Filesystem type of the SFS volume. (Default: STANDARD)                                                                                                                                                                | `string`       | `"STANDARD"`                                                                           |    no    |
| <a name="input_size"></a> [size](#input_size)                                                       | Size of the SFS volume in GB. (Default: 500)                                                                                                                                                                          | `number`       | `500`                                                                                  |    no    |

## Outputs

| Name                                                  | Description |
| ----------------------------------------------------- | ----------- |
| <a name="output_volume"></a> [volume](#output_volume) | n/a         |

<!-- END_TF_DOCS -->

