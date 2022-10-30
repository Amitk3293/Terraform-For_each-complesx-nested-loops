variable "azure_linux_vms" {
  type = map(object({
    size                   = string
    admin_username         = string
    admin_password         = string
    use_ssh_authentication = bool
    ssh_keys               = list(string)
    custom_data            = string
    availability_zone      = string
    network_configuration = object({
      nics = list(object({
        name = string
        ip_configurations = list(object({
          name                                 = string
          subnet_id                            = string
          private_ip_address_allocation_method = string
          private_ip_address                   = string
        }))
      }))

    })
    os_disk_config = object({
      caching              = string
      storage_account_type = string
    })
    source_image_reference = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
  }))
}
