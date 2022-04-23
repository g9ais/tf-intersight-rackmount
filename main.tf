terraform {
  required_providers {
    intersight = {
      source = "CiscoDevNet/intersight"
      version = "1.0.27"
    }
  }
}

//init of intersight provider in provider.tf
//something fishy


resource "intersight_ntp_policy" "ntp1" {
  name        = "${var.prefix}-ntp"
  description = "test policy"
  enabled     = true
  timezone = "Europe/Zurich"
  ntp_servers = [
    "ntp.esl.cisco.com",
    "time-a-g.nist.gov",
    "time-b-g.nist.gov"
  ]
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
  tags = [
      {
          additional_properties = "",
          key = var.intersight_tag.key,
          value = var.intersight_tag.value
      }
  ]
}

# data "intersight_ntp_policy" "ntp1" {
#     name = "${var.prefix}-ntp"
# }

# output "intersight_ntp_policy_Ct" {
#     description = "output creation time ntp policy"
#     value = [
#         for ntppol in data.intersight_ntp_policy.ntp1.results:
#             "${ntppol.name} -> ${ntppol.create_time}"
#     ]
        
# }

resource "intersight_bios_policy" "biospol1" {
  name        = "${var.prefix}-biospol.def"
  description = "bios policy"
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}

resource "intersight_boot_precision_policy" "bootpol1" {
  name                     = "${var.prefix}-bootpol.kvm_ldisk"
  description              = "test policy kvm then local disk"
  configured_boot_mode     = "Uefi"
  enforce_uefi_secure_boot = false
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
  boot_devices {
    enabled     = true
    name        = "kvm"
    object_type = "boot.VirtualMedia"
    additional_properties = jsonencode({
      Subtype = "kvm-mapped-dvd"
    })
  }
  boot_devices {
    enabled     = true
    name        = "RAID1_12"
    object_type = "boot.LocalDisk"
    additional_properties = jsonencode({
      Slot = "HBA"
      Bootloader = {
        Description = ""
        Name        = ""
        ObjectType  = "boot.Bootloader"
        Path        = ""
      }
    })
  }
}



resource "intersight_deviceconnector_policy" "dc_pol1" {
  name            = "${var.prefix}-dc_lockout.off"
  description     = "device connector policy"
  lockout_enabled = false
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
  
}

resource "intersight_vmedia_policy" "vmedia1" {
  name          = "${var.prefix}-vmedia.def"
  description   = "vmedia policy"
  enabled       = true
  encryption    = true
  low_power_usb = true
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
  #mappings {
    # additional_properties   = ""
    # authentication_protocol = "none"
    # class_id                = "vmedia.Mapping"
    # device_type             = "cdd"
    # file_location           = "infra-chx.auslab.cisco.com/software/linux/ubuntu-18.04.5-server-amd64.iso"
    # host_name               = "infra-chx.auslab.cisco.com"
    # is_password_set         = false
    # mount_options           = "RO"
    # mount_protocol          = "nfs"
    # object_type             = "vmedia.Mapping"
    # password                = ""
    # remote_file             = "ubuntu-18.04.5-server-amd64.iso"
    # remote_path             = "/iso/software/linux"
    # sanitized_file_location = "infra-chx.auslab.cisco.com/software/linux/ubuntu-18.04.5-server-amd64.iso"
    # username                = ""
    # volume_name             = "IMC_DVD"
  #}
}

resource "intersight_kvm_policy" "kvm1" {
  name                      = "${var.prefix}-kvm.def"
  description               = "kvm policy"
  enabled                   = true
  maximum_sessions          = 3
  remote_port               = 2069
  enable_video_encryption   = true
  enable_local_server_video = true
  tunneled_kvm_enabled      = true
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}

#---------ETH0-4 and POLICIES DEF------------------

resource "intersight_vnic_eth_network_policy" "ethnetpol_trunk" {
  name = "${var.prefix}-eth_trunk.nat2"
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
  vlan_settings {
    object_type  = "vnic.VlanSettings"
    default_vlan = 2
    mode         = "TRUNK"
  }
}

resource "intersight_vnic_eth_qos_policy" "ethqospol_trust" {
  name           = "${var.prefix}-qos.trust"
  description    = "demo vnic eth qos policy"
  mtu            = 1500
  rate_limit     = 0
  cos            = 0
  burst          = 1024
  priority       = "Best Effort"
  trust_host_cos = true
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}

resource "intersight_vnic_eth_adapter_policy" "ethadptpol_vmware" {
  name                    = "${var.prefix}-ethadapter.vmware"
  rss_settings            = false
  uplink_failback_timeout = 5
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
  vxlan_settings {
    enabled = false
  }

  nvgre_settings {
    enabled = false
  }

  arfs_settings {
    enabled = false
  }

  interrupt_settings {
    coalescing_time = 125
    coalescing_type = "MIN"
    nr_count        = 4
    mode            = "MSIx"
  }
  completion_queue_settings {
    nr_count  = 2
    #ring_size = 1
  }
  rx_queue_settings {
    nr_count  = 1
    ring_size = 512
  }
  tx_queue_settings {
    nr_count  = 1
    ring_size = 256
  }
  tcp_offload_settings {
    large_receive = true
    large_send    = true
    rx_checksum   = true
    tx_checksum   = true
  }
}



# see if can iterate this on amount of nics + trunks. note placement


resource "intersight_vnic_eth_if" "eth0" {
  name  = "eth0"
  order = 0
  placement {
    id       = "MLOM"
    pci_link = 0
    uplink   = 0
  }
  # cdn {
  #   value     = "VIC-1-eth00"
  #   nr_source = "user"
  # }
  # usnic_settings {
  #   cos      = 5
  #   nr_count = 0
  # }
  vmq_settings {
    enabled             = false
    multi_queue_support = false
    num_interrupts      = 1
    num_vmqs            = 1
  }
  lan_connectivity_policy {
    moid        = intersight_vnic_lan_connectivity_policy.vniclancon1.moid
    object_type = "vnic.LanConnectivityPolicy"
  }
  eth_network_policy {
    moid = intersight_vnic_eth_network_policy.ethnetpol_trunk.moid
  }
  eth_adapter_policy {
    moid = intersight_vnic_eth_adapter_policy.ethadptpol_vmware.moid
  }
  eth_qos_policy {
    moid = intersight_vnic_eth_qos_policy.ethqospol_trust.moid
  }
}


resource "intersight_vnic_eth_if" "eth1" {
  name  = "eth1"
  order = 1
  placement {
    id       = "MLOM"
    pci_link = 0
    uplink   = 1
  }
  # cdn {
  #   value     = "VIC-1-eth00"
  #   nr_source = "user"
  # }
  # usnic_settings {
  #   cos      = 5
  #   nr_count = 0
  # }
  vmq_settings {
    enabled             = false
    multi_queue_support = false
    num_interrupts      = 1
    num_vmqs            = 1
  }
  lan_connectivity_policy {
    moid        = intersight_vnic_lan_connectivity_policy.vniclancon1.moid
    object_type = "vnic.LanConnectivityPolicy"
  }
  eth_network_policy {
    moid = intersight_vnic_eth_network_policy.ethnetpol_trunk.moid
  }
  eth_adapter_policy {
    moid = intersight_vnic_eth_adapter_policy.ethadptpol_vmware.moid
  }
  eth_qos_policy {
    moid = intersight_vnic_eth_qos_policy.ethqospol_trust.moid
  }
}


resource "intersight_vnic_eth_if" "eth2" {
  name  = "eth2"
  order = 2
  placement {
    id       = "MLOM"
    pci_link = 0
    uplink   = 0
  }
  # cdn {
  #   value     = "VIC-1-eth00"
  #   nr_source = "user"
  # }
  # usnic_settings {
  #   cos      = 5
  #   nr_count = 0
  # }
  vmq_settings {
    enabled             = false
    multi_queue_support = false
    num_interrupts      = 1
    num_vmqs            = 1
  }
  lan_connectivity_policy {
    moid        = intersight_vnic_lan_connectivity_policy.vniclancon1.moid
    object_type = "vnic.LanConnectivityPolicy"
  }
  eth_network_policy {
    moid = intersight_vnic_eth_network_policy.ethnetpol_trunk.moid
  }
  eth_adapter_policy {
    moid = intersight_vnic_eth_adapter_policy.ethadptpol_vmware.moid
  }
  eth_qos_policy {
    moid = intersight_vnic_eth_qos_policy.ethqospol_trust.moid
  }
}


resource "intersight_vnic_eth_if" "eth3" {
  name  = "eth3"
  order = 3
  placement {
    id       = "MLOM"
    pci_link = 0
    uplink   = 1
  }
  # cdn {
  #   value     = "VIC-1-eth00"
  #   nr_source = "user"
  # }
  # usnic_settings {
  #   cos      = 5
  #   nr_count = 0
  # }
  vmq_settings {
    enabled             = false
    multi_queue_support = false
    num_interrupts      = 1
    num_vmqs            = 1
  }
  lan_connectivity_policy {
    moid        = intersight_vnic_lan_connectivity_policy.vniclancon1.moid
    object_type = "vnic.LanConnectivityPolicy"
  }
  eth_network_policy {
    moid = intersight_vnic_eth_network_policy.ethnetpol_trunk.moid
  }
  eth_adapter_policy {
    moid = intersight_vnic_eth_adapter_policy.ethadptpol_vmware.moid
  }
  eth_qos_policy {
    moid = intersight_vnic_eth_qos_policy.ethqospol_trust.moid
  }
}


resource "intersight_vnic_lan_connectivity_policy" "vniclancon1" {
  name                = "${var.prefix}-lan_4nic"
  description         = "vnic lan connectivity policy"
  iqn_allocation_type = "None"
  placement_mode      = "auto"
  target_platform     = "Standalone"
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
  # not needed to add eth_if's as eth_if ask to be bound to a lan conn policy
  # eth_ifs {
  #   object_type = "vnic.EthIf"
  #   moid        = intersight_vnic_eth_if.eth0.moid
  # }

}


#---------hba0-1 and POLICIES DEF------------------
# add this into var if needed
resource "intersight_vnic_fc_network_policy" "fc_netvsan_A" {
  count = var.fcconnectivity ? 1 : 0
  name = "${var.prefix}-fc_vsan.A.100"
  vsan_settings {
    id = 100
  }
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}
resource "intersight_vnic_fc_network_policy" "fc_netvsan_B" {
  count = var.fcconnectivity ? 1 : 0
  name = "${var.prefix}-fc_vsan.B.200"
  vsan_settings {
    id = 200
  }
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}

resource "intersight_vnic_fc_adapter_policy" "fc_adaptpol_vmware" {
  count = var.fcconnectivity ? 1 : 0
  name                    = "${var.prefix}-fcadapter.vmware"
  error_detection_timeout = 100000
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
  error_recovery_settings {
    enabled           = false
    io_retry_count    = 255
    io_retry_timeout  = 5
    link_down_timeout = 30000
    port_down_timeout = 10000
  }

  flogi_settings {
    retries = 8
    timeout = 4000
  }

  interrupt_settings {
    mode = "MSIx"
  }

  io_throttle_count = 256
  lun_count         = 1024
  lun_queue_depth   = 20

  plogi_settings {
    retries = 8
    timeout = 20000
  }
  resource_allocation_timeout = 10000

  rx_queue_settings {
    #nr_count  = 1
    ring_size = 64
  }
  tx_queue_settings {
    #nr_count  = 1
    ring_size = 64
  }


  scsi_queue_settings {
    nr_count  = 1
    ring_size = 512
  }

}

resource "intersight_vnic_fc_qos_policy" "fcqospol_def" {
  count = var.fcconnectivity ? 1 : 0
  name           = "${var.prefix}-fcqos.def"
  description    = "demo vhba qos policy"
  rate_limit          = 0
  cos                 = 3
  max_data_field_size = 2112
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}

resource "intersight_vnic_fc_if" "fc0" {
  count = var.fcconnectivity ? 1 : 0
  name  = "fc0"
  order = 0
  placement {
    id       = "MLOM"
    pci_link = 0
    uplink   = 0
  }
  persistent_bindings = true
  san_connectivity_policy {
    moid        = intersight_vnic_san_connectivity_policy.vhbasanconn1[0].moid
    object_type = "vnic.SanConnectivityPolicy"
  }
  fc_network_policy {
    moid = intersight_vnic_fc_network_policy.fc_netvsan_A[0].moid
  }
  fc_adapter_policy {
    moid = intersight_vnic_fc_adapter_policy.fc_adaptpol_vmware[0].moid
  }
  fc_qos_policy {
    moid = intersight_vnic_fc_qos_policy.fcqospol_def[0].moid
  }
}

resource "intersight_vnic_fc_if" "fc1" {
  count = var.fcconnectivity ? 1 : 0
  name  = "fc1"
  order = 1
  placement {
    id       = "MLOM"
    pci_link = 0
    uplink   = 1
  }
  persistent_bindings = true
  san_connectivity_policy {
    moid        = intersight_vnic_san_connectivity_policy.vhbasanconn1[0].moid
    object_type = "vnic.SanConnectivityPolicy"
  }
  fc_network_policy {
    moid = intersight_vnic_fc_network_policy.fc_netvsan_B[0].moid
  }
  fc_adapter_policy {
    moid = intersight_vnic_fc_adapter_policy.fc_adaptpol_vmware[0].moid
  }
  fc_qos_policy {
    moid = intersight_vnic_fc_qos_policy.fcqospol_def[0].moid
  }
}


resource "intersight_vnic_san_connectivity_policy" "vhbasanconn1" {
  count = var.fcconnectivity ? 1 : 0
  name              = "${var.prefix}-san_2hba"
  description       = "vhba for server (fcoe based)"
  placement_mode    = "auto"
  target_platform   = "Standalone"
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}


# Adapter config 

resource "intersight_adapter_config_policy" "adaptercfg1" {
  name        = "${var.prefix}-adaptercfg.MLOM"
  description = "test policy"
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
  settings {
    object_type = "adapter.AdapterConfig"
    slot_id     = "MLOM"
    eth_settings {
      lldp_enabled = true
      object_type  = "adapter.EthSettings"
    }
    fc_settings {
      object_type = "adapter.FcSettings"
      fip_enabled = false
    }
    port_channel_settings {
      enabled = false
      object_type = "adapter.PortChannelSettings"
    }
  }
  # profiles {
  #   moid        = server.moid
  #   object_type = "server.Profile"
  # }
}




resource "intersight_networkconfig_policy" "netcfg1" { 
  name                     = "${var.prefix}-netcfg.dns.google"
  description              = "network configuration policy"
  enable_dynamic_dns       = false
  preferred_ipv6dns_server = "::"
  enable_ipv6              = false
  enable_ipv6dns_from_dhcp = false
  preferred_ipv4dns_server = "8.8.8.8"
  alternate_ipv4dns_server = "8.8.4.4"
  alternate_ipv6dns_server = "::"
  dynamic_dns_domain       = ""
  enable_ipv4dns_from_dhcp = false
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
}


resource "intersight_storage_drive_group" "raid_group1" {
  #(RO) type       = 0
  name       = "RAID1_12"
  raid_level = "Raid1"
  manual_drive_group {
    span_groups {
      slots = "1-2"
    }
  }
  virtual_drives {
    name                = "OS"
    size                = 0
    expand_to_available = true
    boot_drive          = true
    virtual_drive_policy {
      strip_size    = 64
      write_policy  = "Default"
      read_policy   = "Default"
      access_policy = "Default"
      drive_cache   = "Default"
      object_type   = "storage.VirtualDrivePolicy"
    }
  }
  storage_policy {
     moid = intersight_storage_storage_policy.storpol1.moid
  }
}


resource "intersight_storage_storage_policy" "storpol1" {
  name                     = "${var.prefix}-storpolicy.raid1_12"
  use_jbod_for_vd_creation = false
  description              = "storage policy ssd in raid 1 for boot"
  unused_disks_state       = "NoChange"
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
  global_hot_spares = ""
  m2_virtual_drive {
    enable      = false
    object_type = "storage.M2VirtualDriveConfig"
  }
  # drive_group {
  #   moid = intersight_storage_drive_group.raid_group1.moid
  #   object_type = "storage.DriveGroup"
  # }
  # always indicate on child which is its parent, not that a parent has a child.
}





#-----------------------------------------------------------

resource "intersight_server_profile" "server1" {
  name   = var.servername
  description = "server profile deployed through terraform"
  action = "No-op"
  tags = [
      {
          additional_properties = "",
          key = var.intersight_tag.key,
          value = var.intersight_tag.value
      }
  ]
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
  target_platform = "Standalone"
  server_assignment_mode = "None"

  policy_bucket = concat ([
   {
     moid = intersight_ntp_policy.ntp1.moid,
     object_type           = "ntp.Policy",
     class_id              = "ntp.Policy",
     additional_properties = "",
     selector              = ""
   },
   {
     moid = intersight_bios_policy.biospol1.moid,
     object_type           = "bios.Policy",
     class_id              = "bios.Policy",
     additional_properties = "",
     selector              = ""
   },
   {
     moid = intersight_boot_precision_policy.bootpol1.moid,
     object_type           = "boot.PrecisionPolicy",
     class_id              = "boot.PrecisionPolicy",
     additional_properties = "",
     selector              = ""
   },
   {
     moid = intersight_deviceconnector_policy.dc_pol1.moid
     object_type           = "deviceconnector.Policy",
     class_id              = "deviceconnector.Policy",
     additional_properties = "",
     selector              = ""
   },
   {
     moid = intersight_vmedia_policy.vmedia1.moid,
     object_type           = "vmedia.Policy",
     class_id              = "vmedia.Policy",
     additional_properties = "",
     selector              = ""
   },
   {
     moid = intersight_kvm_policy.kvm1.moid
     object_type           = "kvm.Policy",
     class_id              = "kvm.Policy",
     additional_properties = "",
     selector              = ""
   },
   {
     moid = intersight_vnic_lan_connectivity_policy.vniclancon1.moid,
     object_type           = "vnic.LanConnectivityPolicy",
     class_id              = "vnic.LanConnectivityPolicy",
     additional_properties = "",
     selector              = ""
   },
   
   {
     moid = intersight_storage_storage_policy.storpol1.moid
     object_type           = "storage.StoragePolicy",
     class_id              = "storage.StoragePolicy",
     additional_properties = "",
     selector              = ""
   }    
  ], var.fcconnectivity ? [{
     moid = intersight_vnic_san_connectivity_policy.vhbasanconn1[0].moid
     object_type           = "vnic.SanConnectivityPolicy",
     class_id              = "vnic.SanConnectivityPolicy",
     additional_properties = "",
     selector              = ""
   }]: [])
}

