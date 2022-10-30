resource "azurerm_network_interface" "azure_linux_vm_nics" {
  for_each            = local.network_configuration_data
  name                = replace(each.key, ":", "-")
  resource_group_name = var.azure_resource_group
  location            = var.azure_region

  dynamic "ip_configuration" {
    for_each = { for ip_config in each.value.ip_configurations : ip_config.name => ip_config }

    content {
      name                          = ip_configuration.key
      subnet_id                     = ip_configuration.value.subnet_id
      private_ip_address_allocation = ip_configuration.value.private_ip_address_allocation_method
      private_ip_address            = ip_configuration.value.private_ip_address
    }
  }
  tags = {
    Environment = var.env
  }
}
resource "azurerm_linux_virtual_machine" "azure_linux_vm" {
  for_each                        = var.azure_linux_vms
  name                            = each.key
  resource_group_name             = var.azure_resource_group
  location                        = var.azure_region
  size                            = each.value.size
  admin_username                  = each.value.admin_username
  disable_password_authentication = each.value.use_ssh_authentication ? true : false
  admin_password                  = each.value.use_ssh_authentication ? null : each.value.admin_password
  zone                            = each.value.availability_zone
  network_interface_ids = [
    for nic in local.network_configuration_data : azurerm_network_interface.azure_linux_vm_nics["${nic.vm}:${nic.name}"].id if nic.vm == "${each.key}"
  ]
  custom_data = each.value.custom_data == null ? null : each.value.custom_data
  dynamic "admin_ssh_key" {
    for_each = each.value.use_ssh_authentication == true ? toset([for ssh_key in each.value.ssh_keys : ssh_key]) : toset([])
    iterator = ssh_key
    content {
      username   = each.value.admin_username
      public_key = file(ssh_key.value)
    }
  }
  os_disk {
    caching              = each.value.os_disk_config.caching
    storage_account_type = each.value.os_disk_config.storage_account_type
  }
  source_image_reference {
    # This information can be found by running az vm image list --all
    publisher = each.value.source_image_reference.publisher
    offer     = each.value.source_image_reference.offer
    sku       = each.value.source_image_reference.sku
    version   = each.value.source_image_reference.version
  }
  tags = {
    Environment = var.env
  }
}